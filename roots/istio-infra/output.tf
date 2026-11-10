output "public_gateway_ip" {
  value = azurerm_public_ip.public_gateway.ip_address
}
output "private_gateway_reserved_ip" {
  value = var.private_gateway_reserved_ip
}
output "public_gateway_fqdn" {
  value = azurerm_public_ip.public_gateway.fqdn
}
output "dns_fqdn" {
  value = var.dns_zone_name == "" ? null : trimsuffix(azurerm_dns_a_record.public_gateway[0].fqdn, ".")
}
output "public_hostname" {
  value = var.dns_zone_name == "" ? azurerm_public_ip.public_gateway.fqdn : trimsuffix(azurerm_dns_a_record.public_gateway[0].fqdn, ".")
}
