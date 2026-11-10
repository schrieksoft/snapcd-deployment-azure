// azrandom generates these straight into the Server's Key Vault, so their values are not in this state file.

resource "azrandom_cryptographic_key" "token_signing" {
  name      = "snapcd-server-token-signing-key"
  algorithm = "RSA"
  keepers   = var.keepers
}

resource "azrandom_cryptographic_key" "token_encryption" {
  name      = "snapcd-server-token-encryption-key"
  algorithm = "HMAC"
  keepers   = var.keepers
}

resource "azrandom_string" "admin_password" {
  name             = "snapcd-server-admin-password"
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "-_#!"
  keepers          = var.keepers
}

resource "azrandom_string" "runner_client_secret" {
  name    = "snapcd-runner-client-secret"
  length  = 40
  special = false
  keepers = var.keepers
}

resource "azrandom_string" "agent_client_secret" {
  name    = "snapcd-agent-client-secret"
  length  = 40
  special = false
  keepers = var.keepers
}

// The Server reads these two as bare base64, and azrandom stores HMAC keys PEM-wrapped.
resource "random_bytes" "state_store" {
  length  = 32
  keepers = var.keepers
}

resource "random_bytes" "secret_store" {
  length  = 32
  keepers = var.keepers
}

resource "azurerm_key_vault_secret" "state_store" {
  name         = "snapcd-server-state-store-key"
  value        = random_bytes.state_store.base64
  key_vault_id = var.snapcd_server_akv_id
}

resource "azurerm_key_vault_secret" "secret_store" {
  name         = "snapcd-server-secret-store-key"
  value        = random_bytes.secret_store.base64
  key_vault_id = var.snapcd_server_akv_id
}
