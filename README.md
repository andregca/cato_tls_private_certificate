# TLS Inspection Certificate Generator

This project automates the generation and validation of a Root CA and a TLS Inspection certificate for use in TLS inspection platforms.
The focus here is to use with the Cato Networks Management Platform (CMA)

## 🗂 Files Included

- `gencert.sh` — Main script to generate CA and TLS inspection certificates
- `environment.sh` — Environment configuration (certificate names, folders, and config files)
- `validate-cert.sh` — Validation script to check certificate compliance
- `install-ca-windows.bat` — Script to install the CA certificate on Windows (Trusted Root Store)
- `ca.cnf` — OpenSSL config for the Root CA
- `tlsi.cnf` — OpenSSL config for the TLS Inspection certificate

## 📦 Requirements

- Bash 3.2+ (Linux/macOS/WSL)
- OpenSSL installed and available in `PATH`
- Windows Administrator access to install the certificate (for `install-ca-windows.bat`)

## ⚙️ How to Use

### 1. Configure your environment

Edit `environment.sh` to set your certificate names and configuration files:

```bash
CA_PREFIX="acme-ca-root"
TLSI_PREFIX="tlsi-acme"
CERT_DIR="all-certs"
INSTALL_DIR="install-certs"
CA_CONFIG="ca.cnf"
TLSI_CONFIG="tlsi.cnf"
```

### 2. Generate certificates

Run the generation script:

```bash
chmod +x gencert.sh
./gencert.sh
```

Certificates will be stored in `all-certs/` and copied to `install-certs/` for installation.

### 3. Validate the certificates

To confirm that the generated certificates meet required standards:

```bash
chmod +x validate-cert.sh
./validate-cert.sh
```

### 4. Install the CA on Windows (run as Administrator)

From the directory containing the `.pem` file and `.bat` script:

```cmd
install-ca-windows.bat acme-ca-root.pem
```

## 📁 Output Structure

```
all-certs/
├── acme-ca-root.pem         (CA Certificate)
├── acme-ca-root.key         (CA Private Key)
├── acme-ca-root.srl         (CA Serial Number)
├── tlsi-acme.crt            (TLS Inspection Certificate)
├── tlsi-acme.key            (TLS Inspection Private Key)
└── tlsi-acme.csr            (TLS Inspection CSR)

install-certs/
├── acme-ca-root.pem         (Install on devices/browsers)
├── tlsi-acme.crt            (Upload to inspection platform)
└── tlsi-acme.key            (Upload to inspection platform)
```

## ✅ Compliance Checks

The `validate-cert.sh` script checks:

- Signature algorithm (SHA256)
- Minimum key size (2048 bits)
- Basic Constraints: CA\:TRUE
- Key Usage: Certificate Sign, CRL Sign
- Authority Key Identifier
- Certificate Chain
- Key match
- Expiration dates
- File sizes

## 📌 Notes

- Always run `install-ca-windows.bat` as Administrator
- Modify `CA_PREFIX` and `TLSI_PREFIX` if running multiple environments
- The OpenSSL config files `ca.cnf` and `tlsi.cnf` must match your policy requirements

## 🔒 Security Warning

Do not reuse these certificates in production without adapting configurations and protecting private keys appropriately.

---

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

> [https://www.apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

---

**Author:** [Andre Gustavo Albuquerque](https://github.com/andregca)  
**Github Repo:**: https://github.com/andregca/cato_tls_private_certificate