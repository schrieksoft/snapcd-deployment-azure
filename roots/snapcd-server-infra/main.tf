data "azurerm_client_config" "current" {}

module "akv" {
  source                          = "../../modules/akv"
  name                            = var.name
  name_type                       = "prefix"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  sku_name                        = "standard"
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = true
  // The identity running this job writes the generated secrets in snapcd_server_infra_config.
  administrator_object_ids = distinct([var.administrator_object_id, data.azurerm_client_config.current.object_id])
}

module "workload_identity" {
  source                  = "../../modules/workload-identity"
  resource_group_name     = var.resource_group_name
  location                = var.location
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  namespace               = var.name
  service_account         = var.name
}

resource "azurerm_role_assignment" "akv_secrets_user" {
  scope                = module.akv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}

/////////////////////////////////////////////////////////////////
// Azure SQL
/////////////////////////////////////////////////////////////////

resource "random_string" "mssql_server" {
  length  = 8
  numeric = true
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_mssql_server" "this" {
  name                = "${var.name}-${random_string.mssql_server.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  version             = "12.0"
  minimum_tls_version = "1.2"

  azuread_administrator {
    azuread_authentication_only = true
    login_username              = "administrators"
    object_id                   = var.administrator_object_id
  }
}

resource "azurerm_mssql_virtual_network_rule" "apps" {
  name      = "apps"
  server_id = azurerm_mssql_server.this.id
  subnet_id = var.apps_subnet_id
}

data "http" "bootstrap_runner_ip" {
  count = var.allow_bootstrap_runner_ip ? 1 : 0
  url   = "https://api.ipify.org"
}

resource "azurerm_mssql_firewall_rule" "bootstrap_runner" {
  count            = var.allow_bootstrap_runner_ip ? 1 : 0
  name             = "bootstrap-runner"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = trimspace(data.http.bootstrap_runner_ip[0].response_body)
  end_ip_address   = trimspace(data.http.bootstrap_runner_ip[0].response_body)
}

resource "azurerm_mssql_database" "this" {
  name        = var.name
  server_id   = azurerm_mssql_server.this.id
  sku_name    = var.sql_database_sku
  max_size_gb = var.sql_database_max_size_gb
  collation   = "SQL_Latin1_General_CP1_CI_AS"
}

// Key Vault data-plane role assignments take a few minutes to apply.
resource "time_sleep" "role_propagation" {
  depends_on      = [module.akv, azurerm_role_assignment.akv_secrets_user, azurerm_mssql_firewall_rule.bootstrap_runner]
  create_duration = "120s"
}
