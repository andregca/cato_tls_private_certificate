#!/bin/bash

# Environment variables for file prefixes
CA_PREFIX="acme-ca-root"
TLSI_PREFIX="tlsi-acme"
CERT_DIR="all-certs"
INSTALL_DIR="install-certs"
CA_CONFIG="ca.cnf"
TLSI_CONFIG="tlsi.cnf"

# File paths
CA_KEY="$CERT_DIR/$CA_PREFIX.key"
CA_PEM="$CERT_DIR/$CA_PREFIX.pem"
CA_SRL="$CERT_DIR/$CA_PREFIX.srl"
TLSI_KEY="$CERT_DIR/$TLSI_PREFIX.key"
TLSI_CSR="$CERT_DIR/$TLSI_PREFIX.csr"
TLSI_CRT="$CERT_DIR/$TLSI_PREFIX.crt"