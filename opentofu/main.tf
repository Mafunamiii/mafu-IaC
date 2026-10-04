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

# OS DISK =============================================
# OS disk used by the Azure Linux VM.
resource "azurerm_managed_disk" "os" {
  name                = "MafuServer_OsDisk_1_05b5bb24163f407ca178d768b69559b4"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Match the existing 30 GB OS disk.
  disk_size_gb = 30

  # Match the existing Standard SSD storage tier.
  storage_account_type = "StandardSSD_LRS"

  # This disk was originally created from the Debian 12 Gen2 image.
  create_option = "FromImage"

  # Match the existing Hyper-V generation.
  hyper_v_generation = "V2"

  # Linux OS disk.
  os_type = "Linux"

  # Match the existing availability zone.
  zone = "1"

  # Match the existing Trusted Launch configuration.
  trusted_launch_enabled = true

  # Use the exact image version that created the existing disk.
  image_reference_id = "/Subscriptions/4ba3fb67-53c0-4e3d-b1fc-843a8293851e/Providers/Microsoft.Compute/Locations/southeastasia/Publishers/debian/ArtifactTypes/VMImage/Offers/debian-12/Skus/12-gen2/Versions/0.20260909.2596"
}
