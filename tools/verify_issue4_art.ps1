[CmdletBinding()]
param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'
$manifests = @(
  (Join-Path $RepoRoot 'art_production\issue4\approved_A_manifest.csv'),
  (Join-Path $RepoRoot 'art_production\issue4\approved_BC_manifest.csv')
)
$seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$verified = 0
foreach ($manifestPath in $manifests) {
  foreach ($row in Import-Csv -LiteralPath $manifestPath) {
    $runtimePath = if ($row.target_runtime_path) { $row.target_runtime_path } else { $row.runtime_path }
    if (-not $runtimePath.StartsWith('assets/art/match3/')) { throw "Unexpected runtime path: $runtimePath" }
    if (-not $seen.Add($runtimePath)) { throw "Duplicate runtime path: $runtimePath" }
    $path = Join-Path $RepoRoot ($runtimePath -replace '/', '\')
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing approved export: $runtimePath" }
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne $row.export_sha256.ToLowerInvariant()) { throw "$runtimePath SHA-256 mismatch: $hash" }
    $bytes = [IO.File]::ReadAllBytes($path)
    if ($bytes.Length -lt 26 -or [Convert]::ToHexString($bytes[0..7]) -ne '89504E470D0A1A0A' -or [Text.Encoding]::ASCII.GetString($bytes,12,4) -ne 'IHDR') { throw "$runtimePath is not a valid PNG." }
    $width = [System.Net.IPAddress]::NetworkToHostOrder([BitConverter]::ToInt32([byte[]]$bytes[16..19],0))
    $height = [System.Net.IPAddress]::NetworkToHostOrder([BitConverter]::ToInt32([byte[]]$bytes[20..23],0))
    $dimensions = if ($row.export_dimensions) { $row.export_dimensions } else { $row.export_dimensions }
    $expected = $dimensions -split 'x' | ForEach-Object { [int]$_ }
    if ($width -ne $expected[0] -or $height -ne $expected[1]) { throw "$runtimePath dimensions ${width}x${height} != $dimensions." }
    if ($bytes[24] -ne 8 -or $bytes[25] -ne 6) { throw "$runtimePath is not 8-bit RGBA." }
    $verified++
  }
}
if ($verified -ne 37) { throw "Expected 37 approved Issue #4 exports, found $verified." }
Write-Output 'Issue #4 approved art integrity passed: 37/37 SHA-256, dimensions and 8-bit RGBA.'
