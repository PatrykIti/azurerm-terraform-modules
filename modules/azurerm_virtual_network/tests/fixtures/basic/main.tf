# Basic Virtual Network Example
# This example demonstrates the minimal configuration required to create a Virtual Network

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this test
resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-bas-${var.random_suffix}"
  location = var.location
}

# Basic Virtual Network configuration
module "virtual_network" {
  source = "../../../"

  name                = var.virtual_network_name != "" ? var.virtual_network_name : "vnet-dpc-bas-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = var.address_space

  # Basic configuration with defaults
  flow_timeout_in_minutes = 4

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Basic"
  }
}
