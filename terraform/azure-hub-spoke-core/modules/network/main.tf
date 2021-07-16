resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_spaces
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet.address_prefixes }
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value
}
resource "azurerm_network_security_group" "NSG" {
  name                = "NSG-VALIDATION-01"
  location            = var.location
  resource_group_name  = var.resource_group_name

  security_rule {
    name                       = "RULE-1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}