[CmdletBinding()]
param(
    [ValidateSet('Build', 'InstallQa', 'UninstallQa')]
    [string] $Action = 'Build',
    [string] $DeviceSerial,
    [string] $Flutter
)

$ErrorActionPreference = 'Stop'
$qaPackage = 'com.mrweeds.cloudkingdom.qa'
$productionPackage = 'com.mrweeds.cloudkingdom'
$qaAndroidUser = '0'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$flutterApk = Join-Path $repoRoot 'build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk'
$apk = Join-Path $repoRoot 'build/qa/app/outputs/flutter-apk/app-arm64-v8a-debug.apk'

function Get-AndroidSdkRoot {
    foreach ($candidate in @($env:ANDROID_SDK_ROOT, $env:ANDROID_HOME)) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) { return $candidate }
    }

    $propertiesPath = Join-Path $repoRoot 'android/local.properties'
    if (Test-Path -LiteralPath $propertiesPath) {
        $line = Get-Content -LiteralPath $propertiesPath |
            Where-Object { $_ -match '^sdk\.dir=' } |
            Select-Object -First 1
        if ($line) {
            $value = ($line -replace '^sdk\.dir=', '') -replace '\\\\', '\'
            if (Test-Path -LiteralPath $value) { return $value }
        }
    }
    throw 'Android SDK not found. Set ANDROID_SDK_ROOT or ANDROID_HOME, or configure android/local.properties.'
}

function Get-FlutterCommand {
    if ($Flutter) {
        if (Test-Path -LiteralPath $Flutter) { return $Flutter }
        $resolved = Get-Command $Flutter -ErrorAction SilentlyContinue
        if ($resolved) { return $resolved.Source }
        throw "Flutter command '$Flutter' was not found."
    }
    $resolved = Get-Command flutter -ErrorAction SilentlyContinue
    if ($resolved) { return $resolved.Source }

    $propertiesPath = Join-Path $repoRoot 'android/local.properties'
    if (Test-Path -LiteralPath $propertiesPath) {
        $line = Get-Content -LiteralPath $propertiesPath |
            Where-Object { $_ -match '^flutter\.sdk=' } |
            Select-Object -First 1
        if ($line) {
            $sdk = ($line -replace '^flutter\.sdk=', '') -replace '\\\\', '\'
            $candidate = Join-Path $sdk 'bin/flutter.bat'
            if (Test-Path -LiteralPath $candidate) { return $candidate }
        }
    }
    throw 'Flutter not found. Add flutter to PATH or configure flutter.sdk in android/local.properties.'
}

function Get-AaptPath {
    $sdkRoot = Get-AndroidSdkRoot
    $buildTools = Join-Path $sdkRoot 'build-tools'
    $candidate = Get-ChildItem -LiteralPath $buildTools -Directory |
        Sort-Object { [version]$_.Name } -Descending |
        ForEach-Object { Join-Path $_.FullName 'aapt.exe' } |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1
    if (-not $candidate) { throw "aapt.exe was not found under $buildTools." }
    return $candidate
}

function Get-ApkIdentity([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "APK not found: $Path" }
    $aapt = Get-AaptPath
    $badging = & $aapt dump badging $Path 2>&1
    if ($LASTEXITCODE -ne 0) { throw "aapt could not inspect $Path`n$badging" }
    $packageLine = $badging | Where-Object { $_ -match "^package: name='([^']+)'" } | Select-Object -First 1
    if (-not $packageLine -or $packageLine -notmatch "^package: name='([^']+)' versionCode='([^']*)' versionName='([^']*)'") {
        throw "Could not parse Android package metadata from $Path."
    }
    $packageName = $Matches[1]
    $versionCode = $Matches[2]
    $versionName = $Matches[3]
    $sdkLine = $badging | Where-Object { $_ -match "^sdkVersion:'([^']+)'" } | Select-Object -First 1
    $minSdk = if ($sdkLine -match "^sdkVersion:'([^']+)'") { $Matches[1] } else { $null }
    return [pscustomobject]@{
        Package = $packageName
        VersionCode = $versionCode
        VersionName = $versionName
        MinSdk = $minSdk
    }
}

function Assert-TargetDevice {
    if (-not $DeviceSerial) { throw "-DeviceSerial is required for $Action. No device action was taken." }
    $adb = Join-Path (Get-AndroidSdkRoot) 'platform-tools/adb.exe'
    if (-not (Test-Path -LiteralPath $adb)) { throw "adb.exe was not found at $adb." }
    $state = & $adb -s $DeviceSerial get-state 2>&1
    if ($LASTEXITCODE -ne 0 -or ($state -join '').Trim() -ne 'device') {
        throw "ADB device $DeviceSerial is not in the device state: $state"
    }
    return $adb
}

function Assert-QaUserZero([string] $AdbPath) {
    $activeUser = & $AdbPath -s $DeviceSerial shell am get-current-user 2>&1
    if ($LASTEXITCODE -ne 0 -or ($activeUser -join '').Trim() -ne $qaAndroidUser) {
        throw "Refusing QA install: active Android user is not $qaAndroidUser on ${DeviceSerial}: $activeUser"
    }

    $existingQa = & $AdbPath -s $DeviceSerial shell pm path --user $qaAndroidUser $qaPackage 2>&1
    if ($LASTEXITCODE -ne 0 -or -not ($existingQa -match 'package:.+\.apk')) {
        throw "Refusing QA install: existing $qaPackage was not confirmed for Android user $qaAndroidUser on ${DeviceSerial}: $existingQa"
    }

    $packageHelp = & $AdbPath -s $DeviceSerial shell cmd package help 2>&1
    $helpText = $packageHelp -join "`n"
    if ($LASTEXITCODE -ne 0 -or $helpText -notmatch '(?s)install \[-[^\]]*\].*?--user USER_ID' -or
        $helpText -notmatch '--user: install under the given user') {
        throw 'Refusing QA install: Android Package Manager did not confirm an install --user USER_ID option.'
    }
}

Push-Location $repoRoot
try {
    if ($Action -eq 'UninstallQa') {
        $adb = Assert-TargetDevice
        & $adb -s $DeviceSerial uninstall $qaPackage
        if ($LASTEXITCODE -ne 0) { throw "Could not uninstall QA package $qaPackage from $DeviceSerial." }
        Write-Output "Removed only $qaPackage from $DeviceSerial. Production package was not targeted."
        exit 0
    }

    if ($Action -eq 'Build' -or $Action -eq 'InstallQa') {
        $flutterCommand = Get-FlutterCommand
        & $flutterCommand build apk --debug --target-platform android-arm64 --split-per-abi --android-project-arg cloudKingdomQa=true
        if ($LASTEXITCODE -ne 0) { throw "Flutter QA APK build failed with exit code $LASTEXITCODE." }

        $identity = Get-ApkIdentity $flutterApk
        if ($identity.Package -ne $qaPackage) {
            throw "Refusing QA operation: APK package is '$($identity.Package)', expected '$qaPackage'. Production ID '$productionPackage' is never accepted."
        }
        if (-not $identity.MinSdk) { throw 'APK does not declare a minimum Android SDK.' }

        $null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $apk)
        Copy-Item -LiteralPath $flutterApk -Destination $apk -Force

        $commit = (& git -C $repoRoot rev-parse HEAD).Trim()
        $hash = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash.ToLowerInvariant()
        $metadataPath = Join-Path $repoRoot 'build/qa/qa-build-metadata.json'
        $metadata = [ordered]@{
            variant = 'debug-arm64-v8a'
            applicationId = $identity.Package
            versionCode = $identity.VersionCode
            versionName = $identity.VersionName
            minSdk = $identity.MinSdk
            gitCommit = $commit
            apk = 'build/qa/app/outputs/flutter-apk/app-arm64-v8a-debug.apk'
            sha256 = $hash
            verifiedUtc = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
        $metadata | ConvertTo-Json | Set-Content -LiteralPath $metadataPath -Encoding utf8
        Write-Output "Verified QA APK: $apk"
        Write-Output "Package: $($identity.Package); version $($identity.VersionName) ($($identity.VersionCode)); minSdk $($identity.MinSdk)"
        Write-Output "SHA-256: $hash"
        Write-Output "Build metadata: $metadataPath"
    }

    if ($Action -eq 'InstallQa') {
        $adb = Assert-TargetDevice
        Assert-QaUserZero $adb
        $remoteApk = "/data/local/tmp/cloudkingdom-qa-$hash.apk"
        & $adb -s $DeviceSerial push $apk $remoteApk
        if ($LASTEXITCODE -ne 0) { throw "Could not stage the verified QA APK on $DeviceSerial; no package installation was attempted." }
        $remoteHashResult = & $adb -s $DeviceSerial shell sha256sum $remoteApk 2>&1
        if ($LASTEXITCODE -ne 0 -or (($remoteHashResult -join ' ') -notmatch [regex]::Escape($hash))) {
            throw "Staged QA APK hash did not match the local verified artifact: $remoteHashResult. No package installation was attempted."
        }
        & $adb -s $DeviceSerial shell cmd package install -r --user $qaAndroidUser $remoteApk
        if ($LASTEXITCODE -ne 0) { throw "Android Package Manager rejected the QA-only install for user $qaAndroidUser on $DeviceSerial. No uninstall or data-clear fallback was attempted." }
        $installed = & $adb -s $DeviceSerial shell pm path --user $qaAndroidUser $qaPackage 2>&1
        if ($LASTEXITCODE -ne 0 -or -not ($installed -match [regex]::Escape($qaPackage))) {
            throw "QA package install could not be verified for Android user $qaAndroidUser on ${DeviceSerial}: $installed"
        }
        & $adb -s $DeviceSerial shell rm $remoteApk
        if ($LASTEXITCODE -ne 0) { Write-Warning "The verified QA APK remains staged at $remoteApk; package install and user 0 verification succeeded." }
        Write-Output "Installed and verified only $qaPackage for Android user $qaAndroidUser on $DeviceSerial. Reinstall used -r; no app data was cleared."
    }
} finally {
    Pop-Location
}
