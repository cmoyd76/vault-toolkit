#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."

echo "🧹 Cleaning up Vault environment..."

# Stop and remove Docker containers and volumes
echo "🛑 Stopping and removing Vault container and volumes..."
docker compose -f "$ROOT_DIR/docker-compose.yml" down --volumes

# Remove generated certificates
CERT_DIR="$ROOT_DIR/config/certs"
if [ -d "$CERT_DIR" ]; then
  echo "🗑️ Removing TLS certificates from $CERT_DIR..."
  rm -rf "$CERT_DIR"
else
  echo "⚠️ No certificates found to remove in $CERT_DIR"
fi

# Remove generated Vault keys file
KEYS_FILE="$ROOT_DIR/vault_keys.txt"
if [ -f "$KEYS_FILE" ]; then
  echo "🗑️ Removing Vault keys file: $KEYS_FILE..."
  rm -f "$KEYS_FILE"
else
  echo "⚠️ Vault keys file not found: $KEYS_FILE"
fi

# Optional: Clear data directory
DATA_DIR="$ROOT_DIR/data/vault_data"
LOG_DIR="$ROOT_DIR/data/vault_logs"
echo "📦 Cleaning up data and log directories..."
rm -rf "$DATA_DIR"/*
rm -rf "$LOG_DIR"/*

echo "✅ Cleanup complete."
