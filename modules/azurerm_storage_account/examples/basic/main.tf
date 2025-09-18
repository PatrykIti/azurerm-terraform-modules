terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
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

module "storage_account" {
  source = "../../"

  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Basic example uses secure defaults (shared access keys disabled)
  # To enable shared access keys, uncomment the following:
  # security_settings = {
  #   shared_access_key_enabled = true
  # }

  # Create a container for basic storage usage
  containers = [
    {
      name                  = "logs"
      container_access_type = "private"
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}