
resource "azurerm_public_ip" "public_gateway" {
  name                = "istio-public-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.public_gateway_domain_name_label
}

data "azurerm_dns_zone" "this" {
  count               = var.dns_zone_name == "" ? 0 : 1
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
}

// Alias record: follows the public IP if its address changes.
resource "azurerm_dns_a_record" "public_gateway" {
  count               = var.dns_zone_name == "" ? 0 : 1
  name                = var.dns_record_name
  zone_name           = data.azurerm_dns_zone.this[0].name
  resource_group_name = data.azurerm_dns_zone.this[0].resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.public_gateway.id
}
