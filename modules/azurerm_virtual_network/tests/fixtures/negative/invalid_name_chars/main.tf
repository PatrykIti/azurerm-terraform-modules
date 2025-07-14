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
  source = "../../../../"

  # Invalid: name contains spaces (invalid characters)
  name                = "vnet with spaces"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}