[CmdletBinding()]
param(
    [ValidateSet('Build', 'InstallQa', 'BuildProfileQa', 'InstallProfileQa')]
    [string] $Action = 'Build',
    [string] $DeviceSerial,
    [string] $Flutter
)

$ErrorActionPreference = 'Stop'
$qaPackage = 'com.mrweeds.cloudkingdom.qa'
$productionPackage = 'com.mrweeds.cloudkingdom'
$qaAndroidUser = '0'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$qaInstallSafetyModule = Join-Path $PSScriptRoot 'qa_install_safety.psm1'
Import-Module $qaInstallSafetyModule -Force
$buildMode = if ($Action -in @('BuildProfileQa', 'InstallProfileQa')) { 'profile' } else { 'debug' }
$flutterApk = Join-Path $repoRoot "build/app/outputs/flutter-apk/app-arm64-v8a-$buildMode.apk"
$apk = if ($buildMode -eq 'profile') {
    Join-Path $repoRoot 'build/qa/profile/app/outputs/flutter-apk/app-arm64-v8a-profile.apk'
} else {
    Join-Path $repoRoot 'build/qa/app/outputs/flutter-apk/app-arm64-v8a-debug.apk'
}

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

function Get-ApkSignerPath {
    $sdkRoot = Get-AndroidSdkRoot
    $buildTools = Join-Path $sdkRoot 'build-tools'
    $candidate = Get-ChildItem -LiteralPath $buildTools -Directory |
        Sort-Object { [version]$_.Name } -Descending |
        ForEach-Object {
            foreach ($name in @('apksigner.bat', 'apksigner.exe')) {
                $path = Join-Path $_.FullName $name
                if (Test-Path -LiteralPath $path) { return $path }
            }
        } |
        Select-Object -First 1
    if (-not $candidate) { throw "apksigner was not found under $buildTools." }
    return $candidate
}

function Get-ApkSignerSha256([string] $Path) {
    $apksigner = Get-ApkSignerPath
    $details = & $apksigner verify --print-certs $Path 2>&1
    if ($LASTEXITCODE -ne 0) { throw "apksigner could not verify $Path`n$details" }
    $line = $details | Where-Object {
        $_ -match 'Signer #1 certificate SHA-256 digest:\s*([0-9a-fA-F]+)'
    } | Select-Object -First 1
    if (-not $line -or $line -notmatch 'Signer #1 certificate SHA-256 digest:\s*([0-9a-fA-F]+)') {
        throw "Could not read the APK signing certificate SHA-256 from $Path."
    }
    return $Matches[1].ToLowerInvariant()
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

function Assert-QaReplaceIsSafe([string] $AdbPath, [string] $CandidatePath, $CandidateIdentity) {
    $packageInfo = & $AdbPath -s $DeviceSerial shell dumpsys package $qaPackage 2>&1
    if ($LASTEXITCODE -ne 0 -or ($packageInfo -join "`n") -notmatch 'versionCode=(\d+)') {
        throw "Refusing QA install: installed version metadata could not be verified for $qaPackage on user $qaAndroidUser."
    }
    $installedVersionCode = [long]$Matches[1]
    $installedPaths = & $AdbPath -s $DeviceSerial shell pm path --user $qaAndroidUser $qaPackage 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Refusing QA install: installed APK path could not be verified: $installedPaths"
    }
    $basePathLine = $installedPaths | Where-Object { $_ -match '^package:.*/base\.apk$' } | Select-Object -First 1
    if (-not $basePathLine -or $basePathLine -notmatch '^package:(.+)$') {
        throw "Refusing QA install: installed base APK path was not found: $installedPaths"
    }
    $installedApkPath = $Matches[1]

    $candidateSigner = Get-ApkSignerSha256 $CandidatePath
    $tempBase = Join-Path $env:TEMP "cloudkingdom-qa-installed-$([guid]::NewGuid().ToString('N')).apk"
    try {
        & $AdbPath -s $DeviceSerial pull $installedApkPath $tempBase 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $tempBase)) {
            throw 'Refusing QA install: installed QA base APK could not be read to verify its signing certificate.'
        }
        $installedSigner = Get-ApkSignerSha256 $tempBase
        Assert-QaInstallCompatible `
            -CandidatePackage $CandidateIdentity.Package `
            -CandidateVersionCode ([long]$CandidateIdentity.VersionCode) `
            -CandidateSignerSha256 $candidateSigner `
            -InstalledPackage $qaPackage `
            -InstalledVersionCode $installedVersionCode `
            -InstalledSignerSha256 $installedSigner `
            -AndroidUser $qaAndroidUser
    } finally {
        if (Test-Path -LiteralPath $tempBase) {
            Remove-Item -LiteralPath $tempBase -Force
        }
    }
}

Push-Location $repoRoot
try {
    if ($Action -in @('Build', 'InstallQa', 'BuildProfileQa', 'InstallProfileQa')) {
        $flutterCommand = Get-FlutterCommand
        $flutterArguments = @(
            'build', 'apk', "--$buildMode", '--target-platform', 'android-arm64',
            '--split-per-abi', '--android-project-arg', 'cloudKingdomQa=true'
        )
        if ($buildMode -eq 'profile') {
            $flutterArguments += @('--dart-define=CLOUD_KINGDOM_QA_FRAME_TIMING=true')
        }
        & $flutterCommand @flutterArguments
        if ($LASTEXITCODE -ne 0) { throw "Flutter QA $buildMode APK build failed with exit code $LASTEXITCODE." }

        $identity = Get-ApkIdentity $flutterApk
        if ($identity.Package -ne $qaPackage) {
            throw "Refusing QA operation: APK package is '$($identity.Package)', expected '$qaPackage'. Production ID '$productionPackage' is never accepted."
        }
        if (-not $identity.MinSdk) { throw 'APK does not declare a minimum Android SDK.' }

        $null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $apk)
        Copy-Item -LiteralPath $flutterApk -Destination $apk -Force

        $commit = (& git -C $repoRoot rev-parse HEAD).Trim()
        $hash = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash.ToLowerInvariant()
        $signer = Get-ApkSignerSha256 $apk
        $metadataPath = Join-Path $repoRoot "build/qa/$buildMode/qa-build-metadata.json"
        $null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $metadataPath)
        $metadata = [ordered]@{
            variant = "$buildMode-arm64-v8a"
            applicationId = $identity.Package
            versionCode = $identity.VersionCode
            versionName = $identity.VersionName
            minSdk = $identity.MinSdk
            gitCommit = $commit
            apk = [System.IO.Path]::GetRelativePath($repoRoot, $apk)
            sha256 = $hash
            signingCertificateSha256 = $signer
            verifiedUtc = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
        $metadata | ConvertTo-Json | Set-Content -LiteralPath $metadataPath -Encoding utf8
        Write-Output "Verified QA $buildMode APK: $apk"
        Write-Output "Package: $($identity.Package); version $($identity.VersionName) ($($identity.VersionCode)); minSdk $($identity.MinSdk)"
        Write-Output "SHA-256: $hash"
        Write-Output "Signer SHA-256: $signer"
        Write-Output "Build metadata: $metadataPath"
    }

    if ($Action -in @('InstallQa', 'InstallProfileQa')) {
        $adb = Assert-TargetDevice
        Assert-QaUserZero $adb
        Assert-QaReplaceIsSafe $adb $apk $identity
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
