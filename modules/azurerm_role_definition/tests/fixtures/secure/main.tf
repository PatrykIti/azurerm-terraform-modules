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
  name     = "rg-rd-secure-${local.suffix}"
  location = var.location
}

module "role_definition" {
  source = "../../.."

  name        = "custom-role-secure-${local.suffix}"
  scope       = azurerm_resource_group.example.id
  description = "Least-privilege custom role scoped to a resource group"

  permissions = [
    {
      actions = [
        "Microsoft.Resources/subscriptions/resourceGroups/read"
      ]
    }
  ]

  assignable_scopes = [
    azurerm_resource_group.example.id
  ]
}
