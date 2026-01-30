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
  name     = "rg-pgfs-basic-${var.random_suffix}"
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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                = "pgfsbasic${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  server = {
    sku_name           = var.sku_name
    postgresql_version = var.postgresql_version
  }

  authentication = {
    administrator = {
      login    = "pgfsadmin"
      password = random_password.admin.result
    }
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "test" {
  name      = "appdb${var.random_suffix}"
  server_id = module.postgresql_flexible_server.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
