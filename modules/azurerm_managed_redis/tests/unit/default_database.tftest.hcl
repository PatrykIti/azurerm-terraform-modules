# Default database block tests for Managed Redis module

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

run "default_database_can_be_removed" {
  command = plan

  variables {
    default_database = null
  }

  assert {
    condition     = length(azurerm_managed_redis.managed_redis.default_database) == 0
    error_message = "default_database block should be omitted when default_database is null."
  }
}

run "default_database_modules_render" {
  command = plan

  variables {
    default_database = {
      clustering_policy = "EnterpriseCluster"
      eviction_policy   = "NoEviction"
      modules = [
        {
          name = "RedisJSON"
        },
        {
          name = "RediSearch"
          args = "ON_TIMEOUT RETURN"
        }
      ]
    }
  }

  assert {
    condition     = length(azurerm_managed_redis.managed_redis.default_database[0].module) == 2
    error_message = "default_database.module blocks should be rendered from the modules list."
  }
}
