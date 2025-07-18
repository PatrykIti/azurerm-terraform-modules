# Secure Route Table Example

# Resource Group
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-rt-secure-${random_string.suffix.result}"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-rt-secure-${random_string.suffix.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnets
resource "azurerm_subnet" "workload" {
  name                 = "snet-workload-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "snet-firewall-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Network Interface to simulate a Network Virtual Appliance (NVA)
resource "azurerm_network_interface" "nva" {
  name                = "nic-nva-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.firewall.id
    private_ip_address_allocation = "Dynamic"
    # In a real scenario, you would enable IP forwarding
    # enable_ip_forwarding = true 
  }
}

# Secure Route Table
module "route_table" {
  source = "../../"

  name                = "rt-secure-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Disable BGP route propagation to ensure only explicit routes are used
  bgp_route_propagation_enabled = false

  # Force all outbound traffic through the NVA (firewall)
  routes = [
    {
      name                   = "force-to-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = azurerm_network_interface.nva.private_ip_address
    }
  ]

  # Associate with the workload subnet
  subnet_ids_to_associate = [
    azurerm_subnet.workload.id
  ]

  tags = {
    Environment = "Production"
    Example     = "Secure"
    Pattern     = "Forced-Tunneling"
  }
}