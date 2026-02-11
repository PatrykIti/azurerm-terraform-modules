# Output tests for Redis Cache module

mock_provider "azurerm" {
  mock_resource "azurerm_redis_cache" {
    defaults = {
      id                          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/Redis/redisunit"
      name                        = "redisunit"
      resource_group_name         = "test-rg"
      location                    = "northeurope"
      hostname                    = "redisunit.redis.cache.windows.net"
      ssl_port                    = 6380
      port                        = 6379
      primary_access_key          = "primary-key"
      secondary_access_key        = "secondary-key"
      primary_connection_string   = "redisunit:primary"
      secondary_connection_string = "redisunit:secondary"
      identity = [
        {
          type         = "SystemAssigned"
          principal_id = "00000000-0000-0000-0000-000000000000"
          tenant_id    = "11111111-1111-1111-1111-111111111111"
        }
      ]
      tags = {
        Environment = "Test"
      }
    }
  }

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

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/Redis/redisunit"
    error_message = "Output 'id' should return the Redis Cache ID."
  }

  assert {
    condition     = output.name == "redisunit"
    error_message = "Output 'name' should return the Redis Cache name."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.location == "northeurope"
    error_message = "Output 'location' should return the location."
  }

  assert {
    condition     = output.hostname == "redisunit.redis.cache.windows.net"
    error_message = "Output 'hostname' should return the hostname."
  }

  assert {
    condition     = output.ssl_port == 6380
    error_message = "Output 'ssl_port' should return the SSL port."
  }

  assert {
    condition     = output.port == 6379
    error_message = "Output 'port' should return the non-SSL port."
  }

  assert {
    condition     = output.primary_access_key == "primary-key"
    error_message = "Output 'primary_access_key' should return the primary access key."
  }

  assert {
    condition     = output.secondary_access_key == "secondary-key"
    error_message = "Output 'secondary_access_key' should return the secondary access key."
  }

  assert {
    condition     = length(output.firewall_rules) == 0
    error_message = "Output 'firewall_rules' should be empty when no rules are set."
  }

  assert {
    condition     = length(output.linked_servers) == 0
    error_message = "Output 'linked_servers' should be empty when no linked servers are set."
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 0
    error_message = "Output 'diagnostic_settings_skipped' should be empty when no settings are provided."
  }
}
