locals {
  full_name = var.full_name == "" ? "awi--${var.cluster_name}--${var.namespace}--${var.service_account}" : var.full_name
}

resource "azurerm_user_assigned_identity" "this" {
  name                = local.full_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "this" {
  name                = local.full_name
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.cluster_oidc_issuer_url
  subject             = "system:serviceaccount:${var.namespace}:${var.service_account}"
}
