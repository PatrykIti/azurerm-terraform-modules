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
  name     = "rg-managed-redis-basic-example"
  location = var.location
}

module "managed_redis" {
  source = "../../"

  name                = "managed-redis-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  managed_redis = {
    sku_name = "Balanced_B3"
  }

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
