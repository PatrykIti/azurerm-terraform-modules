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

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "random_password" "admin" {
  length      = 24
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

  sku_name           = var.sku_name
  postgresql_version = var.postgresql_version

  administrator_login    = var.administrator_login
  administrator_password = random_password.admin.result

  storage = {
    storage_mb   = 65536
    storage_tier = "P20"
  }

  backup = {
    retention_days               = 30
    geo_redundant_backup_enabled = true
  }

  network = {
    public_network_access_enabled = true
  }

  high_availability = {
    mode = "ZoneRedundant"
  }

  maintenance_window = {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }

  configurations = [
    {
      name  = "log_checkpoints"
      value = "on"
    },
    {
      name  = "log_connections"
      value = "on"
    }
  ]

  firewall_rules = [
    {
      name             = "office-range"
      start_ip_address = "203.0.113.0"
      end_ip_address   = "203.0.113.255"
    },
    {
      name             = "vpn-ip"
      start_ip_address = "198.51.100.10"
      end_ip_address   = "198.51.100.10"
    }
  ]

  diagnostic_settings = [
    {
      name                       = "postgresql-complete"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      log_categories             = ["PostgreSQLLogs"]
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
