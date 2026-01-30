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
  storage_account_name = substr("sara${local.suffix}abac", 0, 24)
}

resource "azurerm_resource_group" "example" {
  name     = "rg-ra-abac-${local.suffix}"
  location = var.location
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "uai-ra-abac-${local.suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "role_assignment" {
  source = "../../.."

  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.example.principal_id
  principal_type       = "ServicePrincipal"
  condition            = "@Resource[Microsoft.Storage/storageAccounts:Name] StringEquals '${azurerm_storage_account.example.name}'"
  condition_version    = "2.0"
}
