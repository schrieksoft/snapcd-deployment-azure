// Generated once and kept in state, so the hostname stays the same across applies.
resource "random_string" "dns_label_suffix" {
  count   = var.public_dns_label_random_suffix ? 1 : 0
  length  = 5
  upper   = false
  special = false
}

locals {
  domain_name_label = var.public_dns_label_random_suffix ? "${var.public_dns_label}-${random_string.dns_label_suffix[0].result}" : var.public_dns_label
  // azurerm plans the public IP's fqdn as unchanged when its label changes, so the name is built here.
  public_gateway_fqdn = "${local.domain_name_label}.${var.location}.cloudapp.azure.com"
}

resource "azurerm_public_ip" "public_gateway" {
  name                = "istio-public-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = local.domain_name_label
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
