#!/bin/bash
set -e

# Create shared network if it doesn't exist
if ! docker network ls | grep -q 'shared_network'; then
  echo "🌐 Creating shared network 'shared_network'..."
  docker network create shared_network
  echo "🌐 Shared network created successfully!"
fi

COMPOSE_FILE="$(dirname "$0")/docker-compose.yml"
SCRIPT_DIR="$(dirname "$0")"

vault_exec() {
  if docker ps --format '{{.Names}}' | grep -q '^vault$'; then
    docker exec vault "$@"
  else
    echo "Vault container is not running. Start it with './vault.sh up'" >&2
    exit 1
  fi
}

usage() {
  echo "\nUsage: ./vault.sh <command>"
  echo "Commands:"
  echo "  up        Generate certs, start Vault, initialize and unseal"
  echo "  down      Stop and remove Vault container and volumes"
  echo "  restart   Restart the Vault container"
  echo "  status    Show Vault container and service status"
  echo "  logs      Tail Vault container logs"
  echo "  cleanup   Run cleanup.sh to reset the environment"
  echo ""
}

case "$1" in
  up)
    echo "🔐 Generating TLS certs..."
    bash "$SCRIPT_DIR/scripts/generate_certs.sh"

    echo "🔼 Starting Vault..."
    docker compose -f "$COMPOSE_FILE" up -d

    echo "🧪 Initializing and unsealing Vault..."
    bash "$SCRIPT_DIR/scripts/init_unseal.sh"
    ;;
  down)
    echo "⏹️ Stopping Vault and removing volumes..."
    docker compose -f "$COMPOSE_FILE" down --volumes
    ;;
  restart)
    echo "🔁 Restarting Vault..."
    docker compose -f "$COMPOSE_FILE" restart
    ;;
  status)
    echo "📦 Vault container status:"
    docker compose -f "$COMPOSE_FILE" ps
    echo ""
    echo "🔍 Vault service status:"
    vault_exec vault status -tls-skip-verify || true
    ;;
  logs)
    echo "📜 Vault logs:"
    docker logs -f vault
    ;;
  cleanup)
    echo "🧹 Running cleanup..."
    bash "$SCRIPT_DIR/scripts/cleanup.sh"
    ;;
  *)
    usage
    exit 1
    ;;
esac

