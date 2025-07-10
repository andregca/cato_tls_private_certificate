#!/bin/bash

# Load environment variables from external file
ENV_FILE="environment.sh"
if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
else
  echo "Error: Environment file '$ENV_FILE' not found."
  exit 1
fi

# Use CA_PEM, TLSI_CRT, TLSI_KEY from environment

echo "=== TLS Inspection Certificate Validation ==="
echo ""

# Check if files exist
if [ ! -f "$TLSI_CRT" ]; then
    echo "❌ Certificate file not found"
    exit 1
fi

if [ ! -f "$TLSI_KEY" ]; then
    echo "❌ Private key file not found"
    exit 1
fi

if [ ! -f "$CA_PEM" ]; then
    echo "❌ CA certificate file not found"
    exit 1
fi

# 1. Check signature algorithm
echo "1. Checking Signature Algorithm..."
sig_algo=$(openssl x509 -in "$TLSI_CRT" -text -noout | grep "Signature Algorithm" | head -1 | awk '{print $3}')
if [ "$sig_algo" == "sha256WithRSAEncryption" ]; then
    echo "   ✅ Signature Algorithm: $sig_algo"
else
    echo "   ❌ Invalid Signature Algorithm: $sig_algo"
fi

# 2. Check key size
echo "2. Checking Key Size..."
key_size=$(openssl x509 -in "$TLSI_CRT" -text -noout | grep "Public-Key" | grep -o '[0-9]\+')
if [ "$key_size" -ge 2048 ]; then
    echo "   ✅ Key Size: $key_size bits"
else
    echo "   ❌ Key Size too small: $key_size bits (minimum 2048)"
fi

# 3. Check Basic Constraints
echo "3. Checking Basic Constraints..."
basic_constraints=$(openssl x509 -in "$TLSI_CRT" -text -noout | grep -A 1 "X509v3 Basic Constraints")
if echo "$basic_constraints" | grep -q "CA:TRUE"; then
    echo "   ✅ Basic Constraints: CA:TRUE found"
else
    echo "   ❌ Basic Constraints: CA:TRUE not found"
fi

# 4. Check Key Usage
echo "4. Checking Key Usage..."
key_usage=$(openssl x509 -in "$TLSI_CRT" -text -noout | grep -A 1 "X509v3 Key Usage")
if echo "$key_usage" | grep -q "Certificate Sign" && echo "$key_usage" | grep -q "CRL Sign"; then
    echo "   ✅ Key Usage: Certificate Sign, CRL Sign found"
else
    echo "   ❌ Key Usage: Missing Certificate Sign or CRL Sign"
fi

# 5. Check Authority Key Identifier
echo "5. Checking Authority Key Identifier..."
auth_key_id=$(openssl x509 -in "$TLSI_CRT" -text -noout | grep -A 1 "X509v3 Authority Key Identifier")
if [ -n "$auth_key_id" ]; then
    echo "   ✅ Authority Key Identifier: Present"
else
    echo "   ❌ Authority Key Identifier: Missing"
fi

# 6. Verify certificate chain
echo "6. Verifying Certificate Chain..."
chain_result=$(openssl verify -CAfile "$CA_PEM" "$TLSI_CRT" 2>&1)
if echo "$chain_result" | grep -q "OK"; then
    echo "   ✅ Certificate Chain: Valid"
else
    echo "   ❌ Certificate Chain: Invalid"
    echo "   Error: $chain_result"
fi

# 7. Check private key match
echo "7. Checking Private Key Match..."
cert_modulus=$(openssl x509 -in "$TLSI_CRT" -noout -modulus | openssl md5)
key_modulus=$(openssl rsa -in "$TLSI_KEY" -noout -modulus 2>/dev/null | openssl md5)

if [ "$cert_modulus" = "$key_modulus" ]; then
    echo "   ✅ Private Key: Matches certificate"
else
    echo "   ❌ Private Key: Does not match certificate"
fi

# 8. Check certificate validity
echo "8. Checking Certificate Validity..."
validity=$(openssl x509 -in "$TLSI_CRT" -noout -dates)
echo "   🗕 $validity"

# 9. Check file sizes
echo "9. Checking File Sizes..."
cert_size=$(wc -c < "$TLSI_CRT")
key_size_file=$(wc -c < "$TLSI_KEY")
echo "   📊 Certificate size: $cert_size bytes"
echo "   📊 Private key size: $key_size_file bytes"

echo ""
echo "=== Validation Complete ==="
echo "Files ready for installation:"
echo "📁 $INSTALL_DIR/"
echo "  ├── $CA_PREFIX.pem                         (Install on all devices)"
echo "  ├── $TLSI_PREFIX.crt                      (Upload to Cato platform)"
echo "  └── $TLSI_PREFIX.key                      (Upload to Cato platform)"
