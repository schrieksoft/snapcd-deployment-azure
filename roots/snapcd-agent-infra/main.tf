module "workload_identity" {
  source                  = "../../modules/workload-identity"
  resource_group_name     = var.resource_group_name
  location                = var.location
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  namespace               = var.namespace
  service_account         = "snapcd-agent"
}

// Scoped to the one secret, so the Agent cannot read the Server's keys.
resource "azurerm_role_assignment" "client_secret_user" {
  scope                = "${var.snapcd_server_akv_id}/secrets/${var.snapcd_agent_client_secret_name}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}
