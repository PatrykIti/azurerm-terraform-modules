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

module "postgresql_flexible_server" {
  source = "../../"

  name                = var.server_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  server = {
    sku_name           = var.sku_name
    postgresql_version = var.postgresql_version
    create_mode = {
      mode                              = "PointInTimeRestore"
      source_server_id                  = var.source_server_id
      point_in_time_restore_time_in_utc = var.restore_time_utc
    }
  }

  tags = {
    Environment = "Development"
    Example     = "PointInTimeRestore"
  }
}
