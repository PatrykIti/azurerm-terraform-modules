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

data "azurerm_client_config" "current" {}

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
  source = "../../"

  name                = var.server_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = var.sku_name
  postgresql_version = var.postgresql_version

  administrator_login    = var.administrator_login
  administrator_password = random_password.admin.result

  authentication = {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  active_directory_administrator = {
    principal_name = var.aad_admin_principal_name
    object_id      = var.aad_admin_object_id
    principal_type = var.aad_admin_principal_type
  }

  tags = {
    Environment = "Development"
    Example     = "AadAuth"
  }
}
