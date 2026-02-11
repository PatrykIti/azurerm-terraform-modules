# Default values tests for Redis Cache module

mock_provider "azurerm" {
  mock_resource "azurerm_redis_cache" {}
  mock_resource "azurerm_redis_firewall_rule" {}
  mock_resource "azurerm_redis_linked_server" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "redisunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  sku_name            = "Standard"
  family              = "C"
  capacity            = 1
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.public_network_access_enabled == true
    error_message = "public_network_access_enabled should default to true."
  }

  assert {
    condition     = var.minimum_tls_version == "1.2"
    error_message = "minimum_tls_version should default to 1.2."
  }

  assert {
    condition     = var.non_ssl_port_enabled == false
    error_message = "non_ssl_port_enabled should default to false."
  }

  assert {
    condition     = var.access_keys_authentication_enabled == true
    error_message = "access_keys_authentication_enabled should default to true."
  }

  assert {
    condition     = var.redis_version == "6"
    error_message = "redis_version should default to 6."
  }

  assert {
    condition     = length(var.firewall_rules) == 0
    error_message = "firewall_rules should be empty by default."
  }

  assert {
    condition     = length(var.patch_schedule) == 0
    error_message = "patch_schedule should be empty by default."
  }

  assert {
    condition     = length(var.linked_servers) == 0
    error_message = "linked_servers should be empty by default."
  }

  assert {
    condition     = length(var.diagnostic_settings) == 0
    error_message = "diagnostic_settings should be empty by default."
  }

  assert {
    condition     = length(var.zones) == 0
    error_message = "zones should be empty by default."
  }

  assert {
    condition     = length(var.tenant_settings) == 0
    error_message = "tenant_settings should be empty by default."
  }
}
