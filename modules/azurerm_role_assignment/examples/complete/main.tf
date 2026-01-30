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

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "role_assignment" {
  source = "../.."

  name                  = var.role_assignment_name
  scope                 = azurerm_storage_account.example.id
  role_definition_name  = "Storage Blob Data Reader"
  principal_id          = azurerm_user_assigned_identity.example.principal_id
  principal_type        = "ServicePrincipal"
  description           = "Role assignment with ABAC condition at storage account scope"
  condition             = "@Resource[Microsoft.Storage/storageAccounts:Name] StringEquals '${azurerm_storage_account.example.name}'"
  condition_version     = "2.0"
  skip_service_principal_aad_check = true
}
