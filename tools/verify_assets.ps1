$root = "https://invariant.pro"
$urls = @(
  "$root/papers/Zero_Drift_Neural_Computation.pdf",
  "$root/proof/canonical_run_proof.json",
  "$root/figures/energy_vs_step.png",
  "$root/figures/topology_schedule.png",
  "$root/figures/psi_replay.png"
)

Write-Host "`n=== INVARIANT Asset Verification ===" -ForegroundColor Cyan
Write-Host "Checking live assets..." -ForegroundColor DarkCyan

foreach ($u in $urls) {
  try {
    $r = Invoke-WebRequest -Uri $u -Method Head -ErrorAction Stop
    $status = if ($r.StatusCode -eq 200) { "OK" } else { "ERROR" }
    $color = if ($r.StatusCode -eq 200) { "Green" } else { "Red" }
    Write-Host ("{0,-60} -> {1,4} | {2}" -f $u, $status, ($r.Headers["Content-Type"])) -ForegroundColor $color
  } catch { 
    Write-Host ("{0,-60} -> ERROR: {1}" -f $u, $_.Exception.Message) -ForegroundColor Red
  }
}

Write-Host "`nDone." -ForegroundColor Cyan
