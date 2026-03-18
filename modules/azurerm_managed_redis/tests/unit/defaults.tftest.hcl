# Defaults tests for Managed Redis module

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

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.managed_redis.high_availability_enabled == true
    error_message = "high_availability_enabled should default to true."
  }

  assert {
    condition     = var.managed_redis.public_network_access == "Enabled"
    error_message = "public_network_access should default to Enabled."
  }

  assert {
    condition     = var.default_database.access_keys_authentication_enabled == false
    error_message = "access_keys_authentication_enabled should default to false."
  }

  assert {
    condition     = var.default_database.client_protocol == "Encrypted"
    error_message = "client_protocol should default to Encrypted."
  }

  assert {
    condition     = var.default_database.clustering_policy == "OSSCluster"
    error_message = "clustering_policy should default to OSSCluster."
  }

  assert {
    condition     = var.default_database.eviction_policy == "VolatileLRU"
    error_message = "eviction_policy should default to VolatileLRU."
  }

  assert {
    condition     = length(var.default_database.modules) == 0
    error_message = "default_database.modules should be empty by default."
  }

  assert {
    condition     = var.geo_replication == null
    error_message = "geo_replication should be null by default."
  }

  assert {
    condition     = length(var.monitoring) == 0
    error_message = "monitoring should be empty by default."
  }
}
