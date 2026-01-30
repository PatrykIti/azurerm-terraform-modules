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

data "azurerm_subscription" "current" {}

module "role_definition" {
  source = "../.."

  name        = var.role_definition_name
  scope       = data.azurerm_subscription.current.id
  description = "Custom role with management and data actions"

  permissions = [
    {
      actions = [
        "Microsoft.Storage/storageAccounts/read",
        "Microsoft.Storage/storageAccounts/listKeys/action"
      ]
      not_actions = [
        "Microsoft.Authorization/*/write"
      ]
      data_actions = [
        "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"
      ]
      not_data_actions = [
        "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete"
      ]
    }
  ]

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}
