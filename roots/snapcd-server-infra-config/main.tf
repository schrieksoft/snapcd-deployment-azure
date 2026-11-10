locals {
  kv = var.key_vault_enabled ? 1 : 0
}

/////////////////////////////////////////////////////////////////
// Database user for the Server's workload identity
/////////////////////////////////////////////////////////////////

data "mssql_database" "this" {
  name = var.snapcd_server_mssql_database_name
}

data "mssql_database_role" "db_owner" {
  name        = "db_owner"
  database_id = data.mssql_database.this.id
}

// Named by client ID, which the Server's SQL transport passes as its Username.
resource "mssql_azuread_service_principal" "this" {
  name        = var.snapcd_server_workload_identity_client_id
  database_id = data.mssql_database.this.id
  client_id   = var.snapcd_server_workload_identity_client_id
}

resource "mssql_database_role_member" "this" {
  role_id   = data.mssql_database_role.db_owner.id
  member_id = mssql_azuread_service_principal.this.id
}

/////////////////////////////////////////////////////////////////
// Keys and secrets, with key_vault_enabled
/////////////////////////////////////////////////////////////////

// azrandom generates these straight into the Server's Key Vault, so their values are not in this state file.

resource "azrandom_cryptographic_key" "token_signing" {
  count     = local.kv
  name      = "snapcd-server-token-signing-key"
  algorithm = "RSA"
  keepers   = var.keepers
}

resource "azrandom_cryptographic_key" "token_encryption" {
  count     = local.kv
  name      = "snapcd-server-token-encryption-key"
  algorithm = "HMAC"
  keepers   = var.keepers
}

resource "azrandom_string" "admin_password" {
  count            = local.kv
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
  count   = local.kv
  name    = "snapcd-runner-client-secret"
  length  = 40
  special = false
  keepers = var.keepers
}

resource "azrandom_string" "agent_client_secret" {
  count   = local.kv
  name    = "snapcd-agent-client-secret"
  length  = 40
  special = false
  keepers = var.keepers
}

// The Server reads these two as bare base64, and azrandom stores HMAC keys PEM-wrapped.
resource "random_bytes" "state_store" {
  count   = local.kv
  length  = 32
  keepers = var.keepers
}

resource "random_bytes" "secret_store" {
  count   = local.kv
  length  = 32
  keepers = var.keepers
}

resource "azurerm_key_vault_secret" "state_store" {
  count        = local.kv
  name         = "snapcd-server-state-store-key"
  value        = random_bytes.state_store[0].base64
  key_vault_id = var.snapcd_server_akv_id
}

resource "azurerm_key_vault_secret" "secret_store" {
  count        = local.kv
  name         = "snapcd-server-secret-store-key"
  value        = random_bytes.secret_store[0].base64
  key_vault_id = var.snapcd_server_akv_id
}
