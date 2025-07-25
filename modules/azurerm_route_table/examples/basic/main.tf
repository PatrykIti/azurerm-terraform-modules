# Basic Route Table Example
# This example creates a basic route table with simple routes

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.36.0"
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

# Create a subnet
resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create the Route Table
module "route_table" {
  source = "../../"

  name                = var.route_table_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Simple routes configuration
  routes = [
    {
      name           = "to-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    },
    {
      name           = "local-vnet"
      address_prefix = "10.0.0.0/16"
      next_hop_type  = "VnetLocal"
    }
  ]

  # Associate with subnet
  subnet_ids_to_associate = [
    azurerm_subnet.example.id
  ]

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
