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

module "role_definition" {
  source = "../.."

  name        = var.role_definition_name
  scope       = azurerm_resource_group.example.id
  description = "Least-privilege custom role scoped to a single resource group"

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
