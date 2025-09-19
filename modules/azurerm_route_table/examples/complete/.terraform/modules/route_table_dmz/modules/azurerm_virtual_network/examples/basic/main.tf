# Basic Virtual Network Example
# This example demonstrates the minimal configuration required to create a Virtual Network

terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
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

# Basic Virtual Network configuration
module "virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.1"

  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  # Basic configuration with defaults
  flow_timeout_in_minutes = 4

  tags = {
    Environment = "Development"
    Example     = "Basic"
    Purpose     = "Virtual Network Basic Example"
  }
}
