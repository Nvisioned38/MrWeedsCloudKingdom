[CmdletBinding()]
param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$base = Join-Path $RepoRoot 'art_production\issue26\track_b_review'
$review = Join-Path $base 'review'
New-Item -ItemType Directory -Force -Path $review | Out-Null

$status = @(
  [pscustomobject]@{Character='Riff';DesignDirectionApproval='Approved/locked reference';StandaloneExportApproval='APPROVED_LOCKED_2026-11-09 (11 exports)';RuntimeReadiness='Integrated into Flutter; S24 visual QA pending';DeviceVisualQA='NOT TESTED';Notes='Exact locked manifest and approval record are bundled under ../.'},
  [pscustomobject]@{Character='Mona Chromatic';DesignDirectionApproval='Approved/locked reference';StandaloneExportApproval='APPROVED_LOCKED_2026-11-09 (11 exports)';RuntimeReadiness='Integrated into Flutter; S24 visual QA pending';DeviceVisualQA='NOT TESTED';Notes='Gold frame retains the approved source background; dialogue image renders uncropped.'},
  [pscustomobject]@{Character='Chef Blaze';DesignDirectionApproval='Design sheet reference approved; standalone export identity not established';StandaloneExportApproval='NOT APPROVED - review crops only';RuntimeReadiness='NOT IMPORTED';DeviceVisualQA='NOT TESTED';Notes='Hero crop is visibly clipped at bottom and has a partial title/logo edge; sheet alpha is partially transparent throughout but contains no transparent pixels.'},
  [pscustomobject]@{Character='Dr. Cloud';DesignDirectionApproval='Design sheet reference approved; standalone export identity not established';StandaloneExportApproval='NOT APPROVED - review crops only';RuntimeReadiness='NOT IMPORTED';DeviceVisualQA='NOT TESTED';Notes='Canonical sheet shows moss-gray/olive Troll and open-topped Cloud Glass; crop candidates are opaque and retain background/panel edges.'},
  [pscustomobject]@{Character='The Collector';DesignDirectionApproval='Design sheet reference approved; standalone export identity not established';StandaloneExportApproval='NOT APPROVED - review crops only';RuntimeReadiness='NOT IMPORTED';DeviceVisualQA='NOT TESTED';Notes='Canonical sheet shows moss-gray Troll; crop candidates are opaque and retain background/panel edges.'}
)
$status | Export-Csv -NoTypeInformation -Encoding utf8 -LiteralPath (Join-Path $review 'character_approval_runtime_status.csv')

$audit = [System.Collections.Generic.List[object]]::new()
foreach ($dir in Get-ChildItem -LiteralPath (Join-Path $base 'candidates') -Directory) {
  foreach ($file in Get-ChildItem -LiteralPath $dir.FullName -Filter '*.png') {
    $bitmap = [System.Drawing.Bitmap]::new($file.FullName)
    $width = $bitmap.Width; $height = $bitmap.Height
    $transparent = 0; $partial = 0; $opaque = 0
    for ($y = 0; $y -lt $height; $y++) {
      for ($x = 0; $x -lt $width; $x++) {
        $alpha = $bitmap.GetPixel($x,$y).A
        if ($alpha -eq 0) { $transparent++ } elseif ($alpha -eq 255) { $opaque++ } else { $partial++ }
      }
    }
    $corners = @($bitmap.GetPixel(0,0).A,$bitmap.GetPixel($width-1,0).A,$bitmap.GetPixel(0,$height-1).A,$bitmap.GetPixel($width-1,$height-1).A) -join ';'
    $bitmap.Dispose()
    $audit.Add([pscustomobject]@{Character=$dir.Name;File=$file.Name;Width=$width;Height=$height;Mode='RGBA';TransparentPixels=$transparent;PartialAlphaPixels=$partial;OpaquePixels=$opaque;CornerAlpha=$corners;Sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash.ToLowerInvariant();ReviewStatus='REVIEW ONLY; no source alpha extraction performed'})
  }
}
$audit | Export-Csv -NoTypeInformation -Encoding utf8 -LiteralPath (Join-Path $review 'candidate_image_audit.csv')

$html = @'
<!doctype html><html><head><meta charset="utf-8"><title>Issue 26 Batch G Owner Review</title><style>body{font:16px Segoe UI,Arial;background:#1a1931;color:#f7f0dd;margin:24px}h1,h2{color:#f0c568}.warning{background:#47304a;border:1px solid #d8a84f;padding:14px;margin:16px 0}.char{display:grid;grid-template-columns:minmax(260px,38%) 1fr;gap:16px;margin:24px 0;padding:16px;border:1px solid #7866a3;border-radius:12px}.source{width:100%;height:auto}.candidates{display:grid;grid-template-columns:repeat(3,minmax(110px,1fr));gap:10px}.candidates img{width:100%;height:180px;object-fit:contain;background:#292744}.candidates figure{margin:0;font-size:12px}.table{overflow:auto}table{border-collapse:collapse;width:100%;font-size:13px}td,th{border:1px solid #776a9a;padding:8px;vertical-align:top}th{background:#30264b}</style></head><body><h1>Issue #26 — Batch G owner review</h1><p>Review-only source crops prepared from unchanged canonical sheets. This package does not approve exports and is not included in Flutter runtime assets.</p><div class="warning"><b>Important:</b> Candidate PNGs retain the canonical sheet backgrounds and framing because no approved standalone alpha exports or per-file hashes exist for Chef Blaze, Dr. Cloud, or The Collector. None of the candidates has fully transparent pixels; Chef crops preserve partial alpha across the source sheet while Dr. Cloud and Collector crops are opaque. The retained backgrounds mean an exterior halo check is not meaningful yet. Chef Blaze's hero candidate is visibly clipped at the bottom and contains an edge of the title panel. Do not import these candidates.</div><h2>Separate approval and runtime readiness</h2><table><tr><th>Character</th><th>Design direction</th><th>Standalone export approval</th><th>Runtime readiness</th><th>Device QA</th><th>Notes</th></tr>
'@
foreach ($entry in $status) {
  $html += '<tr><td>' + [Net.WebUtility]::HtmlEncode($entry.Character) + '</td><td>' + [Net.WebUtility]::HtmlEncode($entry.DesignDirectionApproval) + '</td><td>' + [Net.WebUtility]::HtmlEncode($entry.StandaloneExportApproval) + '</td><td>' + [Net.WebUtility]::HtmlEncode($entry.RuntimeReadiness) + '</td><td>' + [Net.WebUtility]::HtmlEncode($entry.DeviceVisualQA) + '</td><td>' + [Net.WebUtility]::HtmlEncode($entry.Notes) + '</td></tr>'
}
$html += '</table>'
$sourceNames = @{chef_blaze='chef_blaze_LOCKED_SOURCE.png';dr_cloud='dr_cloud_LOCKED_SOURCE.png';the_collector='the_collector_LOCKED_SOURCE.png'}
foreach ($id in @('chef_blaze','dr_cloud','the_collector')) {
  $source = $sourceNames[$id]
  $html += "<section><h2>$id</h2><div class='char'><div><h3>Canonical sheet — unchanged</h3><img class='source' src='../canonical_sources/$source'></div><div><h3>Lossless crop proposals</h3><div class='candidates'>"
  foreach ($file in Get-ChildItem -LiteralPath (Join-Path $base "candidates\$id") -Filter '*.png' | Sort-Object Name) {
    $html += "<figure><img src='../candidates/$id/$($file.Name)'><figcaption>$($file.Name)</figcaption></figure>"
  }
  $html += '</div></div></div></section>'
}
$html += '</body></html>'
Set-Content -LiteralPath (Join-Path $review 'BATCH_G_OWNER_VISUAL_REVIEW.html') -Value $html -Encoding utf8
Write-Output "Created side-by-side owner package metadata for $($audit.Count) candidate images."
