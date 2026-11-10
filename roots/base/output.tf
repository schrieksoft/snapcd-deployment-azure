output "resource_group_name" {
  value = var.resource_group_name
}

output "location" {
  value = var.location
}

output "resource_group_id" {
  value = azurerm_resource_group.this.id
}
