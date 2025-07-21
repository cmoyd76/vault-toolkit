#!/bin/bash
set -e

CERT_DIR="$(dirname "$0")/../config/certs"
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

echo "--- Generating self-signed TLS certificates for Vault ---"

# Clean up old certs
rm -f ca.crt ca.key ca.srl vault.crt vault.key vault.csr openssl.cnf

# Generate CA private key
openssl genrsa -out ca.key 4096
chmod 600 ca.key

# Generate CA cert
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 \
  -out ca.crt -subj "/CN=MyVaultTestCA"

# Generate Vault server key
openssl genrsa -out vault.key 4096
chmod 600 vault.key

# Create OpenSSL config with SANs
cat > openssl.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
C = US
ST = NC
L = Raleigh
O = DevTeam
OU = Vault
CN = localhost

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
IP.2 = 0.0.0.0

[ v3_ca ]
subjectAltName = @alt_names
EOF

# Generate CSR
openssl req -new -key vault.key -out vault.csr -config openssl.cnf

# Sign vault cert with CA and embed SANs
openssl x509 -req -in vault.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out vault.crt -days 365 -sha256 -extfile openssl.cnf -extensions req_ext

chmod 644 vault.crt

# Verify certificate chain
echo "--- Verifying certificate chain ---"
openssl verify -CAfile ca.crt vault.crt

# Show SANs
echo "--- Displaying SANs in vault.crt ---"
openssl x509 -in vault.crt -noout -text | grep -A1 "Subject Alternative Name"

# Cleanup
rm -f vault.csr openssl.cnf ca.srl

echo "--- TLS certificate generation complete. Files are in $CERT_DIR ---"
