#Azure resource group containing the VPS infrastructure.
resource "azurerm_resource_group" "main" {
  name     = "MafuServer"
  location = "southeastasia"
}

# Azure Virtual Network for the VPS.
resource "azurerm_virtual_network" "main" {
  name                = "vnet-southeastasia-1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Private address space used by resources inside this VNet.
  address_space = ["172.16.0.0/16"]
}

# Subnet used by the VPS network interface.
resource "azurerm_subnet" "main" {
  name                 = "snet-southeastasia-1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  # Address range allocated to this subnet.
  address_prefixes = ["172.16.0.0/24"]
}
# Network Security Group providing the Azure-side firewall.
resource "azurerm_network_security_group" "main" {
  name                = "MafuServer-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Allow inbound HTTP traffic for the web server.
resource "azurerm_network_security_rule" "http" {
  name                        = "Allow-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Allow inbound HTTPS traffic for the web server.
resource "azurerm_network_security_rule" "https" {
  name                        = "Allow-HTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}
