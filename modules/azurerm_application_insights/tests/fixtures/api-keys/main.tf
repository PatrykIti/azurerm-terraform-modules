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
  name     = "rg-appins-apikeys-${var.random_suffix}"
  location = var.location
}

module "application_insights" {
  source = "../../.."

  name                = "appi-apikeys-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"

  api_keys = [
    {
      name             = "read-only"
      read_permissions = ["api"]
    },
    {
      name              = "read-write"
      read_permissions  = ["api"]
      write_permissions = ["annotations"]
    }
  ]

  tags = var.tags
}
