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
  name     = var.resource_group_name
  location = var.location
}

module "cognitive_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_cognitive_account?ref=COGv1.0.0"

  name                = var.account_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "Language"
  sku_name = "S0"

  public_network_access_enabled = true
  local_auth_enabled            = true

  tags = var.tags
}
