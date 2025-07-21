# 🔐 Vault TLS & Bootstrap Toolkit

This toolkit simplifies the setup of a secure, self-signed TLS-enabled [HashiCorp Vault](https://www.vaultproject.io/) instance in Docker. It includes automation for certificate generation, Vault initialization, and unsealing.

## 📦 Features

- ✅ Self-signed TLS certificate generation
- 🔐 Automated Vault initialization and unsealing
- 🧰 Simple CLI interface for common operations
- 🧼 One-command cleanup/reset
- 🐳 Vault container managed via Docker Compose

> ⚠️ **For development use only.** Do not use this setup in production environments.

---

## 📦 Requirements

- Docker + Docker Compose
- Unix-like environment (Linux/macOS/WSL)
- `openssl` (for generating certs)
- `jq` (for parsing init output)

---

## 🚀 Quick Start

### 1. Clone this Repository

```bash
git clone https://your-org-or-user/vault-toolkit.git
cd vault-toolkit
```

### 2. Make Shell Scripts Executable

```bash
chmod +x vault.sh scripts/*.sh
```

### 3. Start the Environment

```bash
./vault.sh up
```

This will:

- Generate a self-signed TLS certificate with SANs in `config/certs` (`localhost`, `127.0.0.1`)
- Start the Vault container
- Wait for Vault to be sealed
- Initialize Vault
- Unseal it using 3 out of 5 keys
- Output the root token and unseal keys to `vault_keys.txt`

### 🔐 Login Using Root Token

Find your root token in the `vault_keys.txt` file:

```bash
cat vault_keys.txt | jq -r '.root_token'
```

Paste the token into the UI login screen. `https://localhost:8200`

---

## 🧰 CLI Commands

Use the `vault.sh` script to manage the environment:

| Command   | Description                                           |
|-----------|-------------------------------------------------------|
| `up`      | Generate TLS certs, start, initialize, and unseal Vault |
| `down`    | Stop Vault container and remove volumes               |
| `restart` | Restart the Vault container                           |
| `status`  | Show Vault container and service status               |
| `logs`    | Tail Vault container logs                             |
| `cleanup` | Reset everything: containers, volumes, certs, keys    |

---


## 🔑 Root Token & Keys

After Vault is initialized, secrets are stored in:

```
vault_keys.txt
```

This includes:

- 5 unseal keys
- Root token

You can use these to manually unseal or log in again.

---

## 📁 Project Layout

```bash
.
├── config/
│   ├── vault.hcl            # Vault server configuration
│   └── certs/               # Generated TLS certificates
├── data/
│   ├── vault_data/          # Vault persistent data
│   └── vault_logs/          # Vault logs
├── scripts/
│   ├── generate_certs.sh    # TLS certificate generator
│   ├── init_unseal.sh       # Vault initialization and unseal logic
│   └── cleanup.sh           # Environment cleanup
├── docker-compose.yml
├── vault.sh                 # CLI wrapper for managing the stack
└── vault_keys.txt           # Keys and root token (after first init)
```

---

## 🧼 To Reset Everything

```bash
./vault.sh cleanup
```

This will stop containers, remove volumes, and delete certificates and keys.

---

## 🧑‍💻 Contributing

Contributions welcome! Please submit a pull request or file an issue.

---

## 📜 License

MIT License