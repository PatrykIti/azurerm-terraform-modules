# Basic Route Table Example
# This example creates a minimal route table with secure defaults

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
  name     = "rg-rt-bas-${var.random_suffix}"
  location = var.location
}

# Create the route table
module "route_table" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.3"

  # Basic route table configuration
  name                = "rt-bas-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  # BGP route propagation enabled by default (secure default)
  bgp_route_propagation_enabled = true

  # Routes can be passed dynamically
  routes = var.routes

  tags = {
    Environment = "Test"
    Example     = "Basic"
  }
}
