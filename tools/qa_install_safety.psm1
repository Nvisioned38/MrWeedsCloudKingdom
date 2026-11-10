Set-StrictMode -Version Latest

function Assert-QaInstallCompatible {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $CandidatePackage,
        [Parameter(Mandatory)] [long] $CandidateVersionCode,
        [Parameter(Mandatory)] [string] $CandidateSignerSha256,
        [Parameter(Mandatory)] [string] $InstalledPackage,
        [Parameter(Mandatory)] [long] $InstalledVersionCode,
        [Parameter(Mandatory)] [string] $InstalledSignerSha256,
        [Parameter(Mandatory)] [string] $AndroidUser
    )

    $qaPackage = 'com.mrweeds.cloudkingdom.qa'
    if ($AndroidUser -ne '0') {
        throw "Refusing package update: expected Android user 0, got '$AndroidUser'."
    }
    if ($CandidatePackage -ne $qaPackage -or $InstalledPackage -ne $qaPackage) {
        throw "Refusing package update: both APK and installed package must be $qaPackage."
    }
    if ($CandidateVersionCode -lt $InstalledVersionCode) {
        throw "Refusing downgrade from installed version $InstalledVersionCode to candidate version $CandidateVersionCode. No uninstall fallback is allowed."
    }
    if ([string]::IsNullOrWhiteSpace($CandidateSignerSha256) -or
        [string]::IsNullOrWhiteSpace($InstalledSignerSha256) -or
        -not [string]::Equals(
            $CandidateSignerSha256.Trim(),
            $InstalledSignerSha256.Trim(),
            [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Refusing package update: candidate and installed QA signing certificate SHA-256 values do not match.'
    }
}

Export-ModuleMember -Function Assert-QaInstallCompatible
