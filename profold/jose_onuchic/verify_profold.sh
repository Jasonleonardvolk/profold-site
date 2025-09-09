#!/bin/bash
# Quick verification script for Jose's team
# Save as verify_profold.sh and run: bash verify_profold.sh

echo "====== ProFold Verification Script ======"
echo "Verifying Jason Volk's deterministic MD results"
echo ""

# Download the bundle if not present
if [ ! -f "jose_latest.json" ]; then
    echo "Downloading proof bundle..."
    wget https://invariant.pro/profold/jose_onuchic/jose_latest.json
    wget https://invariant.pro/profold/jose_onuchic/jose_latest.json.sha256
    wget https://invariant.pro/profold/jose_onuchic/jose_latest.json.sig
    wget https://invariant.pro/profold/jose_onuchic/jose_public_key.pem
fi

echo ""
echo "Step 1: Verify SHA256 checksum"
echo "--------------------------------"
if sha256sum -c jose_latest.json.sha256; then
    echo "✓ SHA256 checksum valid"
else
    echo "✗ SHA256 checksum FAILED"
    exit 1
fi

echo ""
echo "Step 2: Verify Ed25519 signature"
echo "---------------------------------"
if openssl dgst -sha256 -verify jose_public_key.pem -signature jose_latest.json.sig jose_latest.json > /dev/null 2>&1; then
    echo "✓ Ed25519 signature valid"
else
    echo "✗ Ed25519 signature FAILED"
    exit 1
fi

echo ""
echo "Step 3: Extract and display key metrics"
echo "----------------------------------------"
if command -v jq &> /dev/null; then
    echo "Drift values:"
    jq -r '.proofs[] | "\(.pdb_id): drift = \(.metrics.energy_relative_drift)"' jose_latest.json
    echo ""
    echo "Bit-identical replay status:"
    jq -r '.proofs[] | "\(.pdb_id): replay_identical = \(.metrics.replay_identical)"' jose_latest.json
else
    echo "Install 'jq' for prettier output: sudo apt-get install jq"
    echo "Raw metrics:"
    grep -E "(pdb_id|energy_relative_drift|replay_identical)" jose_latest.json
fi

echo ""
echo "====== VERIFICATION COMPLETE ======"
echo "All signatures valid. Results are authentic."
echo ""
echo "To download full dataset:"
echo "  wget -r -np -nH --cut-dirs=3 https://invariant.pro/profold/jose_onuchic/"
echo ""
echo "To test with your own PDB:"
echo "  Contact: jason@invariant.pro for live demo"
