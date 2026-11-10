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
  count                = var.key_vault_enabled ? 1 : 0
  scope                = "${var.snapcd_server_akv_id}/secrets/${var.snapcd_agent_client_secret_name}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}
