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
  name     = "rg-pgfs-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-pgfs-${var.random_suffix}"
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
  source = "../../../"

  name                = "pgfscomplete${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  server = {
    sku_name           = "GP_Standard_D4s_v3"
    postgresql_version = "15"
    storage = {
      storage_mb   = 65536
      storage_tier = "P20"
    }
    backup = {
      retention_days               = 30
      geo_redundant_backup_enabled = true
    }
    high_availability = {
      mode = "ZoneRedundant"
    }
    maintenance_window = {
      day_of_week  = 0
      start_hour   = 2
      start_minute = 0
    }
  }

  authentication = {
    administrator = {
      login    = "pgfsadmin"
      password = random_password.admin.result
    }
  }

  network = {
    public_network_access_enabled = true
    firewall_rules = [
      {
        name             = "office-range"
        start_ip_address = "203.0.113.0"
        end_ip_address   = "203.0.113.255"
      }
    ]
  }

  features = {
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
  }

  monitoring = {
    diagnostic_settings = {
      "postgresql-complete" = {
        log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
        log_categories             = ["PostgreSQLLogs"]
        metric_categories          = ["AllMetrics"]
      }
    }
  }

  tags = {
    Environment = "Test"
    Example     = "Complete"
  }
}
