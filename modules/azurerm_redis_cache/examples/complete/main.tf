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

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "redis_cache" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_redis_cache?ref=REDISv1.0.0"

  name                = var.redis_cache_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = "Premium"
  family   = "P"
  capacity = 1

  shard_count = 2

  patch_schedule = [
    {
      day_of_week    = "Sunday"
      start_hour_utc = 2
    },
    {
      day_of_week    = "Wednesday"
      start_hour_utc = 4
    }
  ]

  firewall_rules = [
    {
      name             = "office"
      start_ip_address = "203.0.113.10"
      end_ip_address   = "203.0.113.20"
    }
  ]

  redis_configuration = {
    maxmemory_policy              = "allkeys-lru"
    notify_keyspace_events        = "Ex"
    rdb_backup_enabled            = true
    rdb_backup_frequency          = 60
    rdb_backup_max_snapshot_count = 1
    rdb_storage_connection_string = azurerm_storage_account.example.primary_connection_string
  }

  diagnostic_settings = [
    {
      name                       = "redis-diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
