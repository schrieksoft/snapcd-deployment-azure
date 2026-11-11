module "workload_identity" {
  source                  = "../../modules/workload-identity"
  resource_group_name     = var.resource_group_name
  location                = var.location
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  namespace               = var.name
  service_account         = var.name
}

locals {
  claude_secret   = { OAuthToken = [var.claude_oauth_token_secret_name], ApiKey = [var.anthropic_api_key_secret_name], None = [] }[var.claude_credential]
  backend_secrets = length(local.claude_secret) == 0 ? [] : concat(local.claude_secret, var.github_token_enabled ? [var.github_token_secret_name] : [])
}

data "azurerm_key_vault" "backend" {
  count               = length(local.backend_secrets) == 0 ? 0 : 1
  name                = var.backend_akv_name
  resource_group_name = var.backend_akv_resource_group_name
}

// Scoped to each credential, so the Agent reads nothing else in the backend vault.
resource "azurerm_role_assignment" "backend_secret_user" {
  for_each             = toset(local.backend_secrets)
  scope                = "${data.azurerm_key_vault.backend[0].id}/secrets/${each.value}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}
