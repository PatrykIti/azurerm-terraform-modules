# Basic Subnet Example
# This example demonstrates the minimal configuration required to create a Subnet

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
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create a Virtual Network for the subnet
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
    Example     = "Basic"
    Purpose     = "Subnet Basic Example"
  }
}

# Basic Subnet configuration
module "subnet" {
  source = "../.."

  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Basic configuration with defaults
  service_endpoints                             = []
  service_endpoint_policy_ids                   = []
  delegations                                   = {}
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_virtual_network.example]
}