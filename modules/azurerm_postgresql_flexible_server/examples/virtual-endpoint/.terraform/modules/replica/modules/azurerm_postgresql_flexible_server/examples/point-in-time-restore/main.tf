terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
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

resource "random_password" "admin" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}

module "postgresql_flexible_server" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

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

  authentication = {
    administrator = {
      login    = var.administrator_login
      password = random_password.admin.result
    }
  }

  network = {
    public_network_access_enabled = true
  }

  tags = {
    Environment = "Development"
    Example     = "PointInTimeRestore"
  }
}
