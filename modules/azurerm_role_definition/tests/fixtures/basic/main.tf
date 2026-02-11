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

data "azurerm_subscription" "current" {}

locals {
  suffix = lower(replace(var.random_suffix, "-", ""))
}

module "role_definition" {
  source = "../../.."

  name  = "custom-role-basic-${local.suffix}"
  scope = data.azurerm_subscription.current.id

  permissions = [
    {
      actions = [
        "Microsoft.Resources/subscriptions/resourceGroups/read"
      ]
    }
  ]

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}
