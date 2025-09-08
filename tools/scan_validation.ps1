param(
  [string]$SiteRoot = "D:\Dev\kha\press\domains\invariant.pro\site",
  [switch]$Fix,            # apply safe fixes in-place
  [switch]$Backup          # create .bak files before modifying
)

Write-Host "=== INVARIANT Site Validation Scanner ===" -ForegroundColor Cyan
Write-Host "Root: $SiteRoot" -ForegroundColor DarkCyan

# 1) sanity: expected folders & files
$expected = @(
  @{ Path = "\papers\Zero_Drift_Neural_Computation.pdf"; Type="file" },
  @{ Path = "\proof\canonical_run_proof.json"; Type="file" },
  @{ Path = "\figures\energy_vs_step.png"; Type="file" },
  @{ Path = "\figures\topology_schedule.png"; Type="file" },
  @{ Path = "\figures\psi_replay.png"; Type="file" }
)

$missing = @()
foreach ($e in $expected) {
  $p = Join-Path $SiteRoot $e.Path
  if ($e.Type -eq "file" -and -not (Test-Path $p -PathType Leaf)) { $missing += $e.Path }
  if ($e.Type -eq "dir"  -and -not (Test-Path $p -PathType Container)) { $missing += $e.Path }
}
if ($missing.Count) {
  Write-Host "`n[!] Missing required assets:" -ForegroundColor Yellow
  $missing | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
} else {
  Write-Host "`n[+] All required assets present." -ForegroundColor Green
}

# 2) scan html/js for problems
$files = Get-ChildItem $SiteRoot -Recurse -Include *.html,*.htm,*.js,*.json 2>$null
$issues = @()

function Add-Issue([string]$File,[string]$Desc,[string]$Match){
  $script:issues += [pscustomobject]@{ File=$File; Issue=$Desc; Snippet=$Match }
}

foreach ($f in $files) {
  $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
  if (-not $content) { continue }

  # a) anchors that force download
  if ($content -match '<a[^>]*\sdownload(\s|>|=)') {
    Add-Issue $f.FullName "Anchor forces download (remove 'download' attr)" ($Matches[0])
    if ($Fix) {
      if ($Backup) { Copy-Item $f.FullName "$($f.FullName).bak" -Force }
      $new = $content -replace '(\s)download(\s|>|=)','$1'
      Set-Content $f.FullName $new -Encoding UTF8
    }
  }

  # b) references to /proofs/ (typo); replace with /proof/
  if ($content -match '/proofs/') {
    Add-Issue $f.FullName "Uses /proofs/ (should be /proof/)" "/proofs/"
    if ($Fix) {
      if ($Backup) { Copy-Item $f.FullName "$($f.FullName).bak" -Force }
      $new = $content -replace '/proofs/','/proof/'
      Set-Content $f.FullName $new -Encoding UTF8
    }
  }

  # c) broken proof links to sample names we're not shipping
  if ($content -match '/proof/canonical_run_50k\.json|/proof/sample_proof\.json') {
    Add-Issue $f.FullName "Points at non-existent proof files (use /proof/canonical_run_proof.json)" $Matches[0]
    if ($Fix) {
      if ($Backup) { Copy-Item $f.FullName "$($f.FullName).bak" -Force }
      $new = $content -replace '/proof/canonical_run_50k\.json','/proof/canonical_run_proof.json'
      $new = $new     -replace '/proof/sample_proof\.json','/proof/canonical_run_proof.json'
      Set-Content $f.FullName $new -Encoding UTF8
    }
  }

  # d) content-disposition attachment in meta/scripts (rare but deadly)
  if ($content -match 'Content-Disposition\s*:\s*attachment') {
    Add-Issue $f.FullName "Sets Content-Disposition: attachment (removes inline open)" $Matches[0]
    if ($Fix) {
      if ($Backup) { Copy-Item $f.FullName "$($f.FullName).bak" -Force }
      $new = $content -replace 'Content-Disposition\s*:\s*attachment','Content-Disposition: inline'
      Set-Content $f.FullName $new -Encoding UTF8
    }
  }
}

# 3) look for a Cloudflare Pages _headers file (optional enforcement)
$headersPath = Join-Path $SiteRoot "_headers"
$headersAdvice = @"
# Optional: ensure inline open for PDF/PNG/JSON
# Put this file at: $headersPath

/papers/*
  Content-Type: application/pdf
  Content-Disposition: inline

/figures/*
  Content-Type: image/png
  Content-Disposition: inline

/proof/*
  Content-Type: application/json; charset=utf-8
  Content-Disposition: inline
"@

if (-not (Test-Path $headersPath -PathType Leaf)) {
  Write-Host "`n[i] No _headers file found. Cloudflare will infer MIME types from extensions (usually OK)." -ForegroundColor DarkCyan
  Write-Host "[i] If any browser still downloads instead of opening, add this _headers file:" -ForegroundColor DarkCyan
  Write-Host $headersAdvice
} else {
  Write-Host "`n[+] _headers file exists: $headersPath" -ForegroundColor Green
}

# 4) report
if ($issues.Count) {
  Write-Host "`n=== Findings ===" -ForegroundColor Yellow
  $issues | ForEach-Object {
    Write-Host ("- {0}`n  -> {1}" -f $_.File, $_.Issue) -ForegroundColor Yellow
  }
} else {
  Write-Host "`n[+] No issues found in HTML/JS." -ForegroundColor Green
}

Write-Host "`nDone." -ForegroundColor Cyan
