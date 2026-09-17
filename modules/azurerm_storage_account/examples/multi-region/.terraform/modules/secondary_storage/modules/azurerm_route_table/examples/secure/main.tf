# Secure Route Table Example
# This example demonstrates a maximum-security Route Table configuration suitable for highly sensitive data

terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnets
resource "azurerm_subnet" "workload" {
  name                 = var.subnet_workload_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "firewall" {
  name                 = var.subnet_firewall_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Network Interface to simulate a Network Virtual Appliance (NVA)
resource "azurerm_network_interface" "nva" {
  name                = var.nva_nic_name
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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.1.0"

  name                = var.route_table_name
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

  tags = {
    Environment = "Production"
    Example     = "Secure"
    Pattern     = "Forced-Tunneling"
  }
}

# Subnet Route Table Association - managed at the example level
resource "azurerm_subnet_route_table_association" "workload" {
  subnet_id      = azurerm_subnet.workload.id
  route_table_id = module.route_table.id
}
