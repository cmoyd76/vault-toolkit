#!/bin/bash
set -e

VAULT_DATA_DIR="data/vault_data"
VAULT_LOGS_DIR="data/vault_logs"
VAULT_CACERT_PATH="config/certs/ca.crt"
KEYS_FILE="vault_keys.txt"

mkdir -p "$VAULT_DATA_DIR" "$VAULT_LOGS_DIR"
sudo chown -R 100:100 "$VAULT_DATA_DIR" "$VAULT_LOGS_DIR"

docker compose up -d

echo "Waiting for Vault to be sealed..."
timeout 120 bash -c "
  until docker exec vault vault status  | grep 'Sealed.*true'; do
    sleep 1
  done
"

echo "Initializing Vault..."
INIT_OUTPUT=$(docker exec vault vault operator init -key-shares=5 -key-threshold=3 -format=json )
echo "$INIT_OUTPUT" > "$KEYS_FILE"

UNSEAL_KEYS=($(echo "$INIT_OUTPUT" | jq -r '.unseal_keys_b64[]'))
ROOT_TOKEN=$(echo "$INIT_OUTPUT" | jq -r '.root_token')

for i in {0..2}; do
  docker exec vault vault operator unseal ${UNSEAL_KEYS[$i]} #-tls-skip-verify
done

echo "Vault unsealed. Root Token: $ROOT_TOKEN"
export VAULT_ADDR='https://127.0.0.1:8200'
export VAULT_TOKEN="$ROOT_TOKEN"
export VAULT_CACERT="$(pwd)/$VAULT_CACERT_PATH"

VAULT_ADDR="https://127.0.0.1:8200" VAULT_CACERT="$(pwd)/config/certs/ca.crt"




# set -e

# echo "--- Diagnosing Current Working Directory and Paths ---"
# echo "PWD: $(pwd)"

# KEYS_FILE="vault_keys.txt"
# VAULT_DATA_DIR="data/vault_data"
# VAULT_LOGS_DIR="data/vault_logs"
# VAULT_CACERT_PATH="config/certs/ca.crt"

# mkdir -p "$VAULT_DATA_DIR" "$VAULT_LOGS_DIR"
# sudo chown -R 100:100 "$VAULT_DATA_DIR" "$VAULT_LOGS_DIR"

# echo "--- Starting Vault Container ---"
# docker compose up -d

# echo "Waiting for Vault container to report a status..."
# timeout 120 bash -c '
#   while true; do
#     STATUS=$(docker exec vault vault status 2>&1)
#     EXIT_CODE=$?
#     echo -n "." 1>&2
#     if [[ $EXIT_CODE -eq 0 ]]; then
#       echo -e "\nVault status succeeded."
#       break
#     else
#       echo "$STATUS" | grep -q "connection refused" && sleep 1 && continue
#     fi
#   done
# ' || {
#   echo -e "\n❌ Vault container did not become ready within 120 seconds."
#   docker logs vault | tail -n 20
#   exit 1
# }

# IS_INIT=$(docker exec vault vault status 2>/dev/null | grep 'Initialized' | awk '{print $2}')
# if [[ "$IS_INIT" == "true" ]]; then
#   echo "✅ Vault is already initialized. Skipping init/unseal steps."
#   exit 0
# fi

# echo "Initializing Vault..."
# INIT_OUTPUT=$(docker exec vault vault operator init -key-shares=5 -key-threshold=3 -format=json)
# echo "$INIT_OUTPUT" > "$KEYS_FILE"

# UNSEAL_KEYS=($(echo "$INIT_OUTPUT" | jq -r '.unseal_keys_b64[]'))
# ROOT_TOKEN=$(echo "$INIT_OUTPUT" | jq -r '.root_token')

# echo "Unsealing Vault..."
# for i in $(seq 0 2); do
#     docker exec vault vault operator unseal "${UNSEAL_KEYS[$i]}" > /dev/null
# done

# timeout 60 bash -c "
#   until docker exec vault vault status | grep 'Sealed.*false' > /dev/null; do
#     echo -n '.'; sleep 1;
#   done
# "

# export VAULT_ADDR='https://localhost:8200'
# export VAULT_TOKEN="$ROOT_TOKEN"
# export VAULT_CACERT="$(pwd)/$VAULT_CACERT_PATH"

# echo -e "\n✅ Vault initialized and unsealed."
# echo "VAULT_ADDR: $VAULT_ADDR"
# echo "VAULT_TOKEN: $ROOT_TOKEN"
# echo "VAULT_CACERT: $(pwd)/$VAULT_CACERT_PATH"

# vault status