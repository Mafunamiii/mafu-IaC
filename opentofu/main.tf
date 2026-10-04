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

# Network interface  ======================================
# Subnet used by the VPS network interface.
resource "azurerm_subnet" "main" {
  name                 = "snet-southeastasia-1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  # Address range allocated to this subnet.
  address_prefixes = ["172.16.0.0/24"]
}

# FIREWALL ================================
# Network Security Group providing the Azure-side firewall.
resource "azurerm_network_security_group" "main" {
  name                = "MafuServer-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# NSG ======================================
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

# NIC ==============================================
# Network interface connecting the VM to the Azure virtual network.
resource "azurerm_network_interface" "main" {
  name                = "mafuserver965"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    # Primary network interface configuration.
    name = "ipconfig1"

    # Attach the NIC to the existing subnet.
    subnet_id = azurerm_subnet.main.id

    # Azure dynamically assigns the private IP.
    private_ip_address_allocation = "Dynamic"

    # Attach the existing public IP to this NIC.
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

# PUBLIC IP ==========================================
# Public IPv4 address used to expose the VPS to the internet.
resource "azurerm_public_ip" "main" {
  name                = "MafuServer-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Keep the public IP address stable across VM/network changes.
  allocation_method = "Static"

  # Standard SKU is used by the existing Azure public IP.
  sku = "Standard"

  # Explicitly use IPv4.
  ip_version = "IPv4"
  zones      = ["1"]
}
