# Complete Route Table Example
# This example demonstrates all available features of the route table module

terraform {
  required_version = ">= 1.11.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "test" {
  name     = "rg-rt-com-${var.random_suffix}"
  location = var.location
}

# Create a virtual network for testing route table association
resource "azurerm_virtual_network" "test" {
  name                = "vnet-rt-com-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

# Create subnets to demonstrate route table usage
resource "azurerm_subnet" "frontend" {
  name                 = "snet-frontend-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a network security group for virtual appliance
resource "azurerm_network_security_group" "test" {
  name                = "nsg-nva-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

# Create a network interface for virtual appliance
resource "azurerm_network_interface" "nva" {
  name                  = "nic-nva-${var.random_suffix}"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.frontend.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
  }
}

# Create the route table with comprehensive configuration
module "route_table" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.4"

  # Route table configuration
  name                = "rt-com-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  # BGP route propagation configuration
  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled

  # Define multiple custom routes
  routes = concat([
    {
      name                   = "route-to-internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "Internet"
      next_hop_in_ip_address = null
    },
    {
      name                   = "route-to-nva"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "route-to-vnet-gateway"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualNetworkGateway"
      next_hop_in_ip_address = null
    },
    {
      name                   = "route-local"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VnetLocal"
      next_hop_in_ip_address = null
    },
    {
      name                   = "route-drop-traffic"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "None"
      next_hop_in_ip_address = null
    }
  ], var.additional_routes)

  tags = var.tags
}

# Associate route table with subnets
resource "azurerm_subnet_route_table_association" "frontend" {
  subnet_id      = azurerm_subnet.frontend.id
  route_table_id = module.route_table.id
}

resource "azurerm_subnet_route_table_association" "backend" {
  subnet_id      = azurerm_subnet.backend.id
  route_table_id = module.route_table.id
}
