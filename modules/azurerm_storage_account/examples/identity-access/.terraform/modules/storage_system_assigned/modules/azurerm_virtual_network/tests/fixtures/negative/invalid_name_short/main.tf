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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.3"

  # Invalid: name too short (less than 2 characters)
  name                = "v"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}