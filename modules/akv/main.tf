locals {
  name = var.name_type == "prefix" ? "${var.name}-${random_string.this[0].result}" : var.name
}

resource "random_string" "this" {
  lifecycle {
    ignore_changes = all
  }
  count   = var.name_type == "prefix" ? 1 : 0
  length  = 23 - length(var.name)
  numeric = true
  lower   = true
  upper   = false
  special = false
  #keepers = { "name" : var.name }
}

resource "azurerm_key_vault" "this" {
  name                            = local.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  sku_name                        = var.sku_name
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  tags                            = var.tags

  dynamic "network_acls" {
    for_each = toset(var.network_acls)
    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }
}

// Make the current service principal the administrator of the Azure Key vault
resource "azurerm_role_assignment" "this" {
  for_each             = toset(var.administrator_object_ids)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.key
}
