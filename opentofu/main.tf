# Azure resource group containing the VPS infrastructure.
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
