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

resource "azurerm_user_assigned_identity" "example" {
  name                = var.identity_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

module "role_definition" {
  source = "../../../azurerm_role_definition"

  name        = var.role_definition_name
  scope       = azurerm_resource_group.example.id
  description = "Least-privilege custom role for a single resource group"

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

module "role_assignment" {
  source = "../.."

  scope              = azurerm_resource_group.example.id
  role_definition_id = module.role_definition.role_definition_id
  principal_id       = azurerm_user_assigned_identity.example.principal_id
  principal_type     = "ServicePrincipal"
  description        = "Least-privilege custom role assignment"
}
