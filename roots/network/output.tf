output vnet_id {
    value = azurerm_virtual_network.this.id
}

output system_subnet_id {
    value = azurerm_subnet.system.id
}

output apps_subnet_id {
    value = azurerm_subnet.apps.id
}

output ingress_subnet_id {
    value = azurerm_subnet.ingress.id
}