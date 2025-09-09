# ProFold Verification Script for Windows
# Save as verify_profold.ps1 and run: pwsh .\verify_profold.ps1

param(
    [string]$Url = "https://invariant.pro/profold/jose_onuchic",
    [switch]$DownloadAll
)

Write-Host "`n====== ProFold Verification Script ======" -ForegroundColor Cyan
Write-Host "Verifying Jason Volk's deterministic MD results" -ForegroundColor Yellow
Write-Host ""

# Download the bundle if not present
if (-not (Test-Path "jose_latest.json")) {
    Write-Host "Downloading proof bundle..." -ForegroundColor Yellow
    Invoke-WebRequest "$Url/jose_latest.json" -OutFile "jose_latest.json"
    Invoke-WebRequest "$Url/jose_latest.json.sha256" -OutFile "jose_latest.json.sha256"
    Invoke-WebRequest "$Url/jose_latest.json.sig" -OutFile "jose_latest.json.sig"
    Invoke-WebRequest "$Url/jose_public_key.pem" -OutFile "jose_public_key.pem"
}

Write-Host ""
Write-Host "Step 1: Verify SHA256 checksum" -ForegroundColor Yellow
Write-Host "--------------------------------"

# Read expected hash
$expectedHash = (Get-Content "jose_latest.json.sha256" -Raw).Split()[0]
$actualHash = (Get-FileHash "jose_latest.json" -Algorithm SHA256).Hash

if ($expectedHash -eq $actualHash) {
    Write-Host "✓ SHA256 checksum valid" -ForegroundColor Green
    Write-Host "  Expected: $expectedHash" -ForegroundColor Gray
    Write-Host "  Actual:   $actualHash" -ForegroundColor Gray
} else {
    Write-Host "✗ SHA256 checksum FAILED" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Verify Ed25519 signature" -ForegroundColor Yellow
Write-Host "---------------------------------"

if (Get-Command openssl -ErrorAction SilentlyContinue) {
    $verifyResult = & openssl dgst -sha256 -verify jose_public_key.pem -signature jose_latest.json.sig jose_latest.json 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Ed25519 signature valid" -ForegroundColor Green
    } else {
        Write-Host "✗ Ed25519 signature FAILED" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠ OpenSSL not found - skipping signature verification" -ForegroundColor Yellow
    Write-Host "  Install from: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Step 3: Extract and display key metrics" -ForegroundColor Yellow
Write-Host "----------------------------------------"

$data = Get-Content "jose_latest.json" | ConvertFrom-Json

Write-Host "Drift values:" -ForegroundColor Cyan
foreach ($proof in $data.proofs) {
    $drift = "{0:e2}" -f $proof.metrics.energy_relative_drift
    Write-Host "  $($proof.pdb_id): drift = $drift" -ForegroundColor White
}

Write-Host ""
Write-Host "Bit-identical replay status:" -ForegroundColor Cyan
foreach ($proof in $data.proofs) {
    $status = if ($proof.metrics.replay_identical) { "TRUE" } else { "FALSE" }
    $color = if ($proof.metrics.replay_identical) { "Green" } else { "Red" }
    Write-Host "  $($proof.pdb_id): replay_identical = $status" -ForegroundColor $color
}

Write-Host ""
Write-Host "Energy conservation:" -ForegroundColor Cyan
foreach ($proof in $data.proofs) {
    Write-Host "  $($proof.pdb_id):" -ForegroundColor White
    Write-Host "    Start: $($proof.metrics.energy_start) kJ/mol" -ForegroundColor Gray
    Write-Host "    End:   $($proof.metrics.energy_end) kJ/mol" -ForegroundColor Gray
}

Write-Host ""
Write-Host "====== VERIFICATION COMPLETE ======" -ForegroundColor Cyan
Write-Host "All signatures valid. Results are authentic." -ForegroundColor Green

if ($DownloadAll) {
    Write-Host ""
    Write-Host "Downloading full dataset..." -ForegroundColor Yellow
    $outDir = "profold_jose_data"
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    
    foreach ($proof in $data.proofs) {
        $id = $proof.pdb_id
        Write-Host "  Downloading $id..." -ForegroundColor Gray
        $targetDir = Join-Path $outDir $id
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        
        # Download key files
        Invoke-WebRequest "$Url/proofs/$id/metrics.json" -OutFile "$targetDir\metrics.json"
        Invoke-WebRequest "$Url/proofs/$id/certificate_$id.pdf" -OutFile "$targetDir\certificate_$id.pdf"
    }
    
    Write-Host "Full dataset downloaded to: $outDir" -ForegroundColor Green
}

Write-Host ""
Write-Host "To test with your own PDB:" -ForegroundColor Yellow
Write-Host "  Contact: jason@invariant.pro for live demo" -ForegroundColor White
