# Geo-replication tests for Managed Redis module

mock_provider "azurerm" {
  mock_resource "azurerm_managed_redis" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredisunit"
      default_database = [
        {
          id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredisunit/databases/default"
          port = 10000
        }
      ]
    }
  }
  mock_resource "azurerm_managed_redis_geo_replication" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "managedredisunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  managed_redis = {
    sku_name = "Balanced_B3"
  }
}

run "geo_replication_disabled_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_managed_redis_geo_replication.geo_replication) == 0
    error_message = "Geo-replication resource should not be created by default."
  }
}

run "geo_replication_enabled" {
  command = plan

  variables {
    default_database = {
      geo_replication_group_name = "geo-group"
    }
    geo_replication = {
      linked_managed_redis_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredissecondary"
      ]
    }
  }

  assert {
    condition     = length(azurerm_managed_redis_geo_replication.geo_replication) == 1
    error_message = "Geo-replication resource should be created when geo_replication is configured."
  }

  assert {
    condition     = length(azurerm_managed_redis_geo_replication.geo_replication[0].linked_managed_redis_ids) == 1
    error_message = "Geo-replication resource should include the configured linked Managed Redis IDs."
  }
}
