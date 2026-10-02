# Azure resource group containing the VPS infrastructure.
resource "azurerm_resource_group" "main" {
  name     = "MafuServer"
  location = "southeastasia"
}

