module "workload_identity" {
  source                  = "../../modules/workload-identity"
  resource_group_name     = var.resource_group_name
  location                = var.location
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  namespace               = var.name
  service_account         = var.name
}

// Scoped to the one secret, so the Agent cannot read the Server's keys.
resource "azurerm_role_assignment" "client_secret_user" {
  scope                = "${var.snapcd_server_akv_id}/secrets/${var.snapcd_agent_client_secret_name}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}

data "azurerm_key_vault" "backend" {
  count               = var.backend_akv_name == "" ? 0 : 1
  name                = var.backend_akv_name
  resource_group_name = var.backend_akv_resource_group_name
}

// Scoped to each credential, so the Agent reads nothing else in the backend vault.
resource "azurerm_role_assignment" "backend_secret_user" {
  for_each             = var.backend_akv_name == "" ? toset([]) : toset(compact([var.claude_oauth_token_secret_name, var.github_token_secret_name]))
  scope                = "${data.azurerm_key_vault.backend[0].id}/secrets/${each.value}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}
