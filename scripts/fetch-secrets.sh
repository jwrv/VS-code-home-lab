#!/usr/bin/env bash
# =================================================================
# Secrets Fetcher Script
# =================================================================
#
# This script fetches secrets from Vault or Bitwarden and injects
# them into the environment, making them available to AI-driven
# workflows without manual copy/paste.
#
# USAGE:
#   source scripts/fetch-secrets.sh
#   # Or with specific backend:
#   source scripts/fetch-secrets.sh vault
#   source scripts/fetch-secrets.sh bitwarden
#
# REQUIREMENTS:
#   - vault CLI (for Vault backend)
#   - bw CLI (for Bitwarden backend)
#   - jq (for JSON parsing)
#
# =================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect secrets backend
detect_backend() {
    local backend="${1:-auto}"

    if [[ "$backend" == "auto" ]]; then
        if command -v vault &> /dev/null && [[ -n "${VAULT_ADDR:-}" ]]; then
            echo "vault"
        elif command -v bw &> /dev/null; then
            echo "bitwarden"
        else
            log_error "No secrets backend detected"
            log_error "Install either: vault CLI or bw (Bitwarden) CLI"
            return 1
        fi
    else
        echo "$backend"
    fi
}

# Fetch secrets from HashiCorp Vault
fetch_from_vault() {
    log_info "Fetching secrets from Vault at ${VAULT_ADDR}"

    if [[ -z "${VAULT_TOKEN:-}" ]]; then
        log_warn "VAULT_TOKEN not set, attempting vault login"
        vault login
    fi

    # Fetch AWS/MinIO credentials
    if vault kv get -format=json secret/aws &> /dev/null; then
        log_info "Found AWS credentials in Vault"
        export AWS_ACCESS_KEY_ID=$(vault kv get -field=access_key secret/aws)
        export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=secret_key secret/aws)
    fi

    # Fetch Proxmox credentials
    if vault kv get -format=json secret/proxmox &> /dev/null; then
        log_info "Found Proxmox credentials in Vault"
        export PROXMOX_VE_PASSWORD=$(vault kv get -field=password secret/proxmox)
    fi

    # Fetch Ansible vault password
    if vault kv get -format=json secret/ansible &> /dev/null; then
        log_info "Found Ansible vault password in Vault"
        export ANSIBLE_VAULT_PASSWORD=$(vault kv get -field=password secret/ansible)
        echo "$ANSIBLE_VAULT_PASSWORD" > "${HOME}/.vault_pass"
        chmod 600 "${HOME}/.vault_pass"
        export ANSIBLE_VAULT_PASSWORD_FILE="${HOME}/.vault_pass"
    fi

    # Fetch AI API keys
    if vault kv get -format=json secret/ai-keys &> /dev/null; then
        log_info "Found AI API keys in Vault"
        export ANTHROPIC_API_KEY=$(vault kv get -field=anthropic secret/ai-keys 2>/dev/null || true)
        export OPENAI_API_KEY=$(vault kv get -field=openai secret/ai-keys 2>/dev/null || true)
        export GOOGLE_API_KEY=$(vault kv get -field=google secret/ai-keys 2>/dev/null || true)
    fi

    log_info "Vault secrets loaded successfully"
}

# Fetch secrets from Bitwarden
fetch_from_bitwarden() {
    log_info "Fetching secrets from Bitwarden"

    # Check if logged in
    if ! bw status | jq -e '.status == "unlocked"' &> /dev/null; then
        log_warn "Bitwarden vault is locked, attempting unlock"
        BW_SESSION=$(bw unlock --raw)
        export BW_SESSION
    fi

    # Fetch AWS credentials
    if bw get item "AWS MinIO" &> /dev/null; then
        log_info "Found AWS credentials in Bitwarden"
        export AWS_ACCESS_KEY_ID=$(bw get username "AWS MinIO")
        export AWS_SECRET_ACCESS_KEY=$(bw get password "AWS MinIO")
    fi

    # Fetch Proxmox credentials
    if bw get item "Proxmox" &> /dev/null; then
        log_info "Found Proxmox credentials in Bitwarden"
        export PROXMOX_VE_PASSWORD=$(bw get password "Proxmox")
    fi

    # Fetch Ansible vault password
    if bw get item "Ansible Vault" &> /dev/null; then
        log_info "Found Ansible vault password in Bitwarden"
        export ANSIBLE_VAULT_PASSWORD=$(bw get password "Ansible Vault")
        echo "$ANSIBLE_VAULT_PASSWORD" > "${HOME}/.vault_pass"
        chmod 600 "${HOME}/.vault_pass"
        export ANSIBLE_VAULT_PASSWORD_FILE="${HOME}/.vault_pass"
    fi

    # Fetch AI API keys
    if bw get item "Anthropic API" &> /dev/null; then
        export ANTHROPIC_API_KEY=$(bw get password "Anthropic API")
    fi
    if bw get item "OpenAI API" &> /dev/null; then
        export OPENAI_API_KEY=$(bw get password "OpenAI API")
    fi
    if bw get item "Google API" &> /dev/null; then
        export GOOGLE_API_KEY=$(bw get password "Google API")
    fi

    log_info "Bitwarden secrets loaded successfully"
}

# Main execution
main() {
    local backend=$(detect_backend "${1:-auto}")

    log_info "Using secrets backend: $backend"

    case "$backend" in
        vault)
            fetch_from_vault
            ;;
        bitwarden)
            fetch_from_bitwarden
            ;;
        *)
            log_error "Unknown backend: $backend"
            log_error "Supported backends: vault, bitwarden"
            return 1
            ;;
    esac

    log_info "Secrets fetched and exported to environment"
    log_info "You can now use these secrets in your AI workflows"
}

# Run main function
main "$@"

# =================================================================
# USAGE EXAMPLES
# =================================================================
#
# 1. Auto-detect and fetch secrets:
#    source scripts/fetch-secrets.sh
#
# 2. Fetch from specific backend:
#    source scripts/fetch-secrets.sh vault
#    source scripts/fetch-secrets.sh bitwarden
#
# 3. Use in tasks.json:
#    {
#      "label": "Fetch Secrets",
#      "type": "shell",
#      "command": "source scripts/fetch-secrets.sh && env | grep -E '(AWS|PROXMOX|ANSIBLE|API)'"
#    }
#
# 4. Use in AI workflows:
#    - Tell Claude: "Fetch secrets from Vault and deploy infrastructure"
#    - Claude runs: source scripts/fetch-secrets.sh && terraform apply
#
# =================================================================
# SECURITY NOTES
# =================================================================
#
# - Never commit this script with hardcoded secrets
# - Always use .gitignore for .vault_pass
# - Rotate secrets regularly (monthly)
# - Use short-lived Vault tokens when possible
# - Enable MFA for Bitwarden access
# - Audit secret access logs regularly
#
# =================================================================
