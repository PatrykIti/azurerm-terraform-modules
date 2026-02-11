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

resource "azurerm_user_assigned_identity" "principal" {
  name                = var.principal_identity_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_user_assigned_identity" "delegated" {
  name                = var.delegated_identity_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

module "role_assignment" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_role_assignment?ref=RAv1.0.0"

  scope                                  = azurerm_resource_group.example.id
  role_definition_name                   = "Reader"
  principal_id                           = azurerm_user_assigned_identity.principal.principal_id
  principal_type                         = "ServicePrincipal"
  delegated_managed_identity_resource_id = azurerm_user_assigned_identity.delegated.id
}
