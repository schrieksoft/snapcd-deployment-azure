
//////////////////////////////////////////////////////////////////
// The virtual network
//////////////////////////////////////////////////////////////////

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space_system, var.address_space_apps, var.address_space_ingress]
}

//////////////////////////////////////////////////////////////////
// The "apps" subnet
// This is where we'll deploy general-purpose kubernetes nodes
//////////////////////////////////////////////////////////////////
resource "azurerm_subnet" "apps" {
  name                              = "apps"
  private_endpoint_network_policies = "Enabled"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = [var.address_space_apps]
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.ServiceBus"
  ]
  lifecycle {
    ignore_changes = [
      delegation,
    ]
  }
}

//////////////////////////////////////////////////////////////////
// The "system" subnet
// This is where we'll deploy kubernetes "system" nodes
//////////////////////////////////////////////////////////////////
resource "azurerm_subnet" "system" {
  name                              = "system"
  private_endpoint_network_policies = "Enabled"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = [var.address_space_system]
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.ServiceBus"
  ]
  lifecycle {
    ignore_changes = [
      delegation,
    ]
  }
}


//////////////////////////////////////////////////////////////////
// The "ingress" subnet
// This is the subnet that will be used for load balancers
//////////////////////////////////////////////////////////////////

resource "azurerm_subnet" "ingress" {
  name                              = "ingress"
  private_endpoint_network_policies = "Enabled"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = [var.address_space_ingress]
}

resource "azurerm_route_table" "ingress" {
  name                = "ingress"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_route" "ingress" {
  name                = "ingress"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.ingress.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "ingress" {
  subnet_id      = azurerm_subnet.ingress.id
  route_table_id = azurerm_route_table.ingress.id
}