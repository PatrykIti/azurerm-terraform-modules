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

resource "azurerm_resource_group" "example" {
  name     = "rg-cog-language-${var.random_suffix}"
  location = var.location
}

module "cognitive_account" {
  source = "../../.."

  name                = "coglang${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "Language"
  sku_name = var.sku_name

  public_network_access_enabled = true
  local_auth_enabled            = true

  tags = var.tags
}
