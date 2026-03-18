# Validation tests for Managed Redis module

mock_provider "azurerm" {
  mock_resource "azurerm_managed_redis" {}
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

run "invalid_public_network_access" {
  command = plan

  variables {
    managed_redis = {
      sku_name              = "Balanced_B3"
      public_network_access = "NotValid"
    }
  }

  expect_failures = [
    var.managed_redis,
  ]
}

run "invalid_clustering_policy" {
  command = plan

  variables {
    default_database = {
      clustering_policy = "InvalidPolicy"
    }
  }

  expect_failures = [
    var.default_database,
  ]
}

run "aof_and_rdb_mutually_exclusive" {
  command = plan

  variables {
    default_database = {
      persistence_append_only_file_backup_frequency = "1s"
      persistence_redis_database_backup_frequency   = "1h"
    }
  }

  expect_failures = [
    var.default_database,
  ]
}

run "persistence_conflicts_with_geo_replication" {
  command = plan

  variables {
    default_database = {
      geo_replication_group_name                  = "geo-group"
      persistence_redis_database_backup_frequency = "1h"
    }
  }

  expect_failures = [
    var.default_database,
  ]
}

run "cmk_requires_identity" {
  command = plan

  variables {
    customer_managed_key = {
      key_vault_key_id          = "https://example.vault.azure.net/keys/managedredis/keyversion"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/amr"
    }
  }

  expect_failures = [
    var.customer_managed_key,
  ]
}

run "user_assigned_identity_requires_identity_ids" {
  command = plan

  variables {
    identity = {
      type = "UserAssigned"
    }
  }

  expect_failures = [
    var.identity,
  ]
}

run "geo_replication_requires_group_name" {
  command = plan

  variables {
    geo_replication = {
      linked_managed_redis_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/secondary"
      ]
    }
  }

  expect_failures = [
    var.geo_replication,
  ]
}

run "geo_replication_limits_linked_ids" {
  command = plan

  variables {
    default_database = {
      geo_replication_group_name = "geo-group"
    }
    geo_replication = {
      linked_managed_redis_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/one",
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/two",
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/three",
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/four",
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/five",
      ]
    }
  }

  expect_failures = [
    var.geo_replication,
  ]
}

run "redisearch_requires_no_eviction" {
  command = plan

  variables {
    default_database = {
      eviction_policy = "VolatileLRU"
      modules = [
        {
          name = "RediSearch"
        }
      ]
    }
  }

  expect_failures = [
    var.default_database,
  ]
}
