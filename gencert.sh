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

# Create directories
echo "=== Creating Directory Structure ==="
mkdir -p "$CERT_DIR"
mkdir -p "$INSTALL_DIR"

echo "=== Generating CA Certificate ==="
openssl genrsa -out "$CA_KEY" 2048
openssl req -new -x509 -days 3650 -key "$CA_KEY" -out "$CA_PEM" \
  -config "$CA_CONFIG"

echo "=== Generating TLS Inspection Certificate ==="
openssl genrsa -out "$TLSI_KEY" 2048
openssl req -new -key "$TLSI_KEY" -out "$TLSI_CSR" -config "$TLSI_CONFIG"
openssl x509 -req \
  -in "$TLSI_CSR" \
  -CA "$CA_PEM" \
  -CAkey "$CA_KEY" \
  -CAcreateserial \
  -out "$TLSI_CRT" \
  -days 365 \
  -extensions v3_sign \
  -extfile "$TLSI_CONFIG" \
  -sha256

echo "=== Copying Files for Installation ==="
cp "$CA_PEM" "$INSTALL_DIR/"
cp "$TLSI_CRT" "$INSTALL_DIR/"
cp "$TLSI_KEY" "$INSTALL_DIR/"

echo "=== Verification ==="
echo "Signature Algorithm:"
openssl x509 -in "$TLSI_CRT" -text -noout | grep "Signature Algorithm"

echo "Key Size:"
openssl x509 -in "$TLSI_CRT" -text -noout | grep "Public-Key"

echo "Extensions:"
openssl x509 -in "$TLSI_CRT" -text -noout | grep -A 15 "X509v3 extensions"

echo "=== Certificate Generation Complete ==="
echo "Directory Structure:"
echo "├── $CERT_DIR/"
echo "│   ├── $CA_PREFIX.pem         (CA Certificate)"
echo "│   ├── $CA_PREFIX.key         (CA Private Key)"
echo "│   ├── $CA_PREFIX.srl         (CA Serial Number)"
echo "│   ├── $TLSI_PREFIX.crt       (TLS Inspection Certificate)"
echo "│   ├── $TLSI_PREFIX.key       (TLS Inspection Private Key)"
echo "│   └── $TLSI_PREFIX.csr       (TLS Inspection CSR)"
echo "└── $INSTALL_DIR/"
echo "    ├── $CA_PREFIX.pem         (Install on devices/browsers)"
echo "    ├── $TLSI_PREFIX.crt       (Upload to Cato)"
echo "    └── $TLSI_PREFIX.key       (Upload to Cato)"
echo ""
echo "Next Steps:"
echo "1. Install $CA_PREFIX.pem on all devices (use install-ca-windows.bat)"
echo "2. Upload TLS Inspection cert + key to Cato Management Platform"
