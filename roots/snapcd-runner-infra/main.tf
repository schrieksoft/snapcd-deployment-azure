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
  // The identity running this job writes the generated SSH key in snapcd_runner_infra_config.
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

// Key Vault data-plane role assignments take a few minutes to apply.
resource "time_sleep" "role_propagation" {
  depends_on      = [module.akv, azurerm_role_assignment.akv_secrets_user]
  create_duration = "120s"
}

/////////////////////////////////////////////////////////////////
// Admin rights: this Runner deploys the platform tenancy
/////////////////////////////////////////////////////////////////

data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "subscription" {
  for_each             = toset(["Contributor", "User Access Administrator"])
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = each.value
  principal_id         = module.workload_identity.principal_id
}

resource "azurerm_role_assignment" "cluster_admin" {
  scope                = data.azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = module.workload_identity.principal_id
}
