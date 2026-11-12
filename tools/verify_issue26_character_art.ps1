[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [string]$LockedZipPath
)
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $RepoRoot 'art_production\issue26\Batch_G_Riff_Mona_approved_manifest.csv'
$rows = @(Import-Csv -LiteralPath $manifestPath | Where-Object asset_type -ne 'layout_sheet')
if ($rows.Count -ne 22) { throw "Expected 22 approved standalone rows; found $($rows.Count)." }
$expectedArchiveSha = '23e0a0e1f92d1717344c6ba6d73baf7d266234a83c0903aa8155f5c451adc085'
$archive = $null
if ($LockedZipPath) {
  if (-not (Test-Path -LiteralPath $LockedZipPath -PathType Leaf)) { throw "Locked package not found: $LockedZipPath" }
  $archiveSha = (Get-FileHash -LiteralPath $LockedZipPath -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($archiveSha -ne $expectedArchiveSha) { throw "Locked package SHA-256 mismatch: $archiveSha" }
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $archive = [IO.Compression.ZipFile]::OpenRead($LockedZipPath)
  $approvalCopies = @(
    @('manifest.csv',(Join-Path $RepoRoot 'art_production\issue26\Batch_G_Riff_Mona_approved_manifest.csv')),
    @('README.md',(Join-Path $RepoRoot 'art_production\issue26\Batch_G_Riff_Mona_approval_README.md')),
    @('APPROVAL_LOCK_RECORD.txt',(Join-Path $RepoRoot 'art_production\issue26\Batch_G_Riff_Mona_APPROVAL_LOCK_RECORD.txt'))
  )
  foreach ($copy in $approvalCopies) {
    $member = $archive.GetEntry($copy[0])
    if (-not $member) { throw "Locked archive is missing approval record $($copy[0])." }
    $stream = $member.Open(); $sha256 = [Security.Cryptography.SHA256]::Create()
    $memberHash = [Convert]::ToHexString($sha256.ComputeHash($stream)).ToLowerInvariant()
    $stream.Dispose(); $sha256.Dispose()
    $copyHash = (Get-FileHash -LiteralPath $copy[1] -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($memberHash -ne $copyHash) { throw "Copied approval record differs from the locked archive: $($copy[0])." }
  }
}
$errors = [System.Collections.Generic.List[string]]::new()
foreach ($row in $rows) {
  if ($row.status -ne 'APPROVED_LOCKED_2026-11-09') {
    $errors.Add("$($row.path): approval record is not locked.")
    continue
  }
  $file = [IO.Path]::GetFileName($row.path)
  $path = Join-Path $RepoRoot "assets\art\characters\$file"
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    $errors.Add("Missing runtime file: $path")
    continue
  }
  $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($hash -ne $row.sha256.ToLowerInvariant()) { $errors.Add("$file SHA-256 mismatch: $hash") }
  if ($archive) {
    $member = $archive.GetEntry(($row.path -replace '\\','/'))
    if (-not $member) { $errors.Add("$file is missing from the locked archive.") }
    else {
      $stream = $member.Open()
      $sha256 = [Security.Cryptography.SHA256]::Create()
      $memberHash = [Convert]::ToHexString($sha256.ComputeHash($stream)).ToLowerInvariant()
      $stream.Dispose(); $sha256.Dispose()
      if ($memberHash -ne $hash) { $errors.Add("$file differs from its locked archive member.") }
    }
  }
  $bytes = [IO.File]::ReadAllBytes($path)
  if ($bytes.Length -lt 26 -or [Convert]::ToHexString($bytes[0..7]) -ne '89504E470D0A1A0A' -or [Text.Encoding]::ASCII.GetString($bytes,12,4) -ne 'IHDR') {
    $errors.Add("$file is not a valid PNG IHDR file.")
    continue
  }
  $width = [System.Net.IPAddress]::NetworkToHostOrder([BitConverter]::ToInt32([byte[]]@($bytes[16..19] | ForEach-Object { $_ }),0))
  $height = [System.Net.IPAddress]::NetworkToHostOrder([BitConverter]::ToInt32([byte[]]@($bytes[20..23] | ForEach-Object { $_ }),0))
  $colorType = [int]$bytes[25]
  if ($width -ne [int]$row.width -or $height -ne [int]$row.height) { $errors.Add("$file dimensions ${width}x${height}; expected $($row.width)x$($row.height).") }
  if ($row.mode -eq 'RGBA' -and $colorType -ne 6) { $errors.Add("$file PNG color type $colorType; expected RGBA color type 6.") }
  Write-Output "PASS $($row.character): $file ${width}x${height} RGBA sha256=$hash"
}
if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; throw "Issue #26 artwork integrity failed ($($errors.Count) issue(s))." }
if ($archive) { $archive.Dispose(); Write-Output "Locked archive SHA-256 verified: $expectedArchiveSha" }
Write-Output 'Issue #26 locked asset verification passed: 22/22 files.'
