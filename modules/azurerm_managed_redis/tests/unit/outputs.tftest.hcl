# Output tests for Managed Redis module

mock_provider "azurerm" {
  mock_resource "azurerm_managed_redis" {
    defaults = {
      id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredisunit"
      name                      = "managedredisunit"
      resource_group_name       = "test-rg"
      location                  = "northeurope"
      hostname                  = "managedredisunit.redis.azure.com"
      sku_name                  = "Balanced_B3"
      high_availability_enabled = true
      public_network_access     = "Enabled"
      identity = [
        {
          type         = "SystemAssigned"
          principal_id = "00000000-0000-0000-0000-000000000000"
          tenant_id    = "11111111-1111-1111-1111-111111111111"
        }
      ]
      customer_managed_key = [
        {
          key_vault_key_id          = "https://example.vault.azure.net/keys/managedredis/keyversion"
          user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/amr"
        }
      ]
      default_database = {
        id                                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredisunit/databases/default"
        port                               = 10000
        access_keys_authentication_enabled = true
        client_protocol                    = "Encrypted"
        clustering_policy                  = "OSSCluster"
        eviction_policy                    = "VolatileLRU"
        geo_replication_group_name         = "geo-group"
        primary_access_key                 = "primary-key"
        secondary_access_key               = "secondary-key"
        module = [
          {
            name    = "RedisJSON"
            args    = "INDEXING ON"
            version = "2.0.0"
          }
        ]
      }
      tags = {
        Environment = "Test"
      }
    }
  }

  mock_resource "azurerm_managed_redis_geo_replication" {
    defaults = {
      id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredisunit"
      managed_redis_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredisunit"
      linked_managed_redis_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredissecondary"
      ]
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "managedredisunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  managed_redis = {
    sku_name = "Balanced_B3"
  }
  default_database = {
    geo_replication_group_name = "geo-group"
  }
  geo_replication = {
    linked_managed_redis_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredissecondary"
    ]
  }
}

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/redisEnterprise/managedredisunit"
    error_message = "Output 'id' should return the Managed Redis ID."
  }

  assert {
    condition     = output.name == "managedredisunit"
    error_message = "Output 'name' should return the Managed Redis name."
  }

  assert {
    condition     = output.hostname == "managedredisunit.redis.azure.com"
    error_message = "Output 'hostname' should return the Managed Redis hostname."
  }

  assert {
    condition     = output.public_network_access == "Enabled"
    error_message = "Output 'public_network_access' should return the public network access mode."
  }

  assert {
    condition     = output.default_database.port == 10000
    error_message = "Output 'default_database.port' should return the database port."
  }

  assert {
    condition     = output.default_database_primary_access_key == "primary-key"
    error_message = "Output 'default_database_primary_access_key' should return the primary access key."
  }

  assert {
    condition     = length(output.geo_replication.linked_managed_redis_ids) == 1
    error_message = "Output 'geo_replication' should include one linked Managed Redis ID."
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 0
    error_message = "Output 'diagnostic_settings_skipped' should be empty when no empty monitoring entries are provided."
  }
}
