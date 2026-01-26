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
  length      = 24
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}

module "postgresql_flexible_server" {
  source = "../../../azurerm_postgresql_flexible_server"

  name                = var.server_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  server = {
    sku_name           = var.sku_name
    postgresql_version = var.postgresql_version
    storage = {
      storage_mb   = 65536
      storage_tier = "P20"
    }
    backup = {
      retention_days               = 14
      geo_redundant_backup_enabled = false
    }
    maintenance_window = {
      day_of_week  = 0
      start_hour   = 2
      start_minute = 0
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
    Example     = "Complete-Server"
  }
}

module "postgresql_flexible_server_database" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server_database?ref=PGFSDBv1.0.0"

  server_id = module.postgresql_flexible_server.id
  name      = var.database_name
  charset   = "UTF8"
  collation = "en_US.utf8"
}
