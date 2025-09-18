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

variable "random_suffix" {
  description = "Random suffix for naming resources"
  type        = string
  default     = "test"
}

resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-neg-${var.random_suffix}"
  location = "northeurope"
}

module "virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.1"

  # Invalid: empty address space
  name                = "vnet-empty-address"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = []
}