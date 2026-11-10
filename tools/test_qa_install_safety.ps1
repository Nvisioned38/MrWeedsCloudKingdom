[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'qa_install_safety.psm1') -Force
$package = 'com.mrweeds.cloudkingdom.qa'
$signature = 'aabbccddeeff00112233445566778899'

Assert-QaInstallCompatible -CandidatePackage $package -CandidateVersionCode 2001 `
    -CandidateSignerSha256 $signature -InstalledPackage $package `
    -InstalledVersionCode 2001 -InstalledSignerSha256 $signature -AndroidUser '0'
Assert-QaInstallCompatible -CandidatePackage $package -CandidateVersionCode 2002 `
    -CandidateSignerSha256 $signature -InstalledPackage $package `
    -InstalledVersionCode 2001 -InstalledSignerSha256 $signature -AndroidUser '0'

$blockedCases = @(
    @{ Label = 'version downgrade'; CandidateVersionCode = 2000; Signer = $signature; InstalledPackage = $package; User = '0' },
    @{ Label = 'signer mismatch'; CandidateVersionCode = 2001; Signer = '112233445566'; InstalledPackage = $package; User = '0' },
    @{ Label = 'production package'; CandidateVersionCode = 2001; Signer = $signature; InstalledPackage = 'com.mrweeds.cloudkingdom'; User = '0' },
    @{ Label = 'wrong Android user'; CandidateVersionCode = 2001; Signer = $signature; InstalledPackage = $package; User = '150' }
)

foreach ($case in $blockedCases) {
    $refused = $false
    try {
        Assert-QaInstallCompatible -CandidatePackage $package `
            -CandidateVersionCode $case.CandidateVersionCode `
            -CandidateSignerSha256 $case.Signer -InstalledPackage $case.InstalledPackage `
            -InstalledVersionCode 2001 -InstalledSignerSha256 $signature `
            -AndroidUser $case.User
    } catch {
        $refused = $true
    }
    if (-not $refused) { throw "Safety preflight did not refuse $($case.Label)." }
}

Write-Output 'QA package safety checks passed: same-version replace and upgrade accepted; downgrade, signer mismatch, production identity, and non-user-0 targets refused.'
