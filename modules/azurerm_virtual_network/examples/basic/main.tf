# Basic Virtual Network Example
# This example demonstrates the minimal configuration required to create a Virtual Network

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.35.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-vnet-basic-example"
  location = "West Europe"
}

# Basic Virtual Network configuration
module "virtual_network" {
  source = "../../"

  name                = "vnet-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  # Basic configuration with defaults
  flow_timeout_in_minutes = 4
  prevent_destroy         = false

  tags = {
    Environment = "Development"
    Example     = "Basic"
    Purpose     = "Virtual Network Basic Example"
  }
}
