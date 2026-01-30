terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  suffix = lower(replace(var.random_suffix, "-", ""))
}

resource "azurerm_resource_group" "example" {
  name     = "rg-ra-basic-${local.suffix}"
  location = var.location
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "uai-ra-basic-${local.suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

module "role_assignment" {
  source = "../../.."

  scope                = azurerm_resource_group.example.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.example.principal_id
  principal_type       = "ServicePrincipal"
}
