# Validation tests for Redis Cache module

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

run "invalid_sku_family_combo" {
  command = plan

  variables {
    sku_name = "Premium"
    family   = "C"
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "invalid_capacity_for_standard" {
  command = plan

  variables {
    capacity = 7
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "invalid_minimum_tls" {
  command = plan

  variables {
    minimum_tls_version = "1.3"
  }

  expect_failures = [
    var.minimum_tls_version,
  ]
}

run "invalid_redis_version" {
  command = plan

  variables {
    redis_version = "5"
  }

  expect_failures = [
    var.redis_version,
  ]
}

run "subnet_requires_premium" {
  command = plan

  variables {
    subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "subnet_requires_private_ip" {
  command = plan

  variables {
    sku_name  = "Premium"
    family    = "P"
    capacity  = 1
    subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "subnet_requires_public_access_disabled" {
  command = plan

  variables {
    sku_name                      = "Premium"
    family                        = "P"
    capacity                      = 1
    subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
    private_static_ip_address     = "10.0.1.4"
    public_network_access_enabled = true
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "firewall_requires_public_access" {
  command = plan

  variables {
    public_network_access_enabled = false
    firewall_rules = [
      {
        name             = "office"
        start_ip_address = "203.0.113.10"
        end_ip_address   = "203.0.113.20"
      }
    ]
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "patch_schedule_requires_premium" {
  command = plan

  variables {
    patch_schedule = [
      {
        day_of_week    = "Sunday"
        start_hour_utc = 2
      }
    ]
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "linked_servers_requires_premium" {
  command = plan

  variables {
    linked_servers = [
      {
        name                        = "secondary"
        linked_redis_cache_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/Redis/secondary"
        linked_redis_cache_location = "northeurope"
        server_role                 = "Secondary"
      }
    ]
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "replicas_requires_premium" {
  command = plan

  variables {
    replicas_per_primary = 1
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "shard_count_conflicts_with_replicas" {
  command = plan

  variables {
    sku_name             = "Premium"
    family               = "P"
    capacity             = 1
    shard_count          = 2
    replicas_per_primary = 1
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "replicas_fields_mutually_exclusive" {
  command = plan

  variables {
    sku_name             = "Premium"
    family               = "P"
    capacity             = 1
    replicas_per_primary = 1
    replicas_per_master  = 1
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "access_keys_disabled_requires_ad" {
  command = plan

  variables {
    access_keys_authentication_enabled = false
  }

  expect_failures = [
    azurerm_redis_cache.redis_cache,
  ]
}

run "aof_backup_requires_connection_string" {
  command = plan

  variables {
    redis_configuration = {
      aof_backup_enabled = true
    }
  }

  expect_failures = [
    var.redis_configuration,
  ]
}

run "rdb_backup_requires_connection_string" {
  command = plan

  variables {
    redis_configuration = {
      rdb_backup_enabled = true
    }
  }

  expect_failures = [
    var.redis_configuration,
  ]
}

run "invalid_patch_day" {
  command = plan

  variables {
    sku_name = "Premium"
    family   = "P"
    capacity = 1
    patch_schedule = [
      {
        day_of_week    = "Funday"
        start_hour_utc = 2
      }
    ]
  }

  expect_failures = [
    var.patch_schedule,
  ]
}

run "invalid_patch_hour" {
  command = plan

  variables {
    sku_name = "Premium"
    family   = "P"
    capacity = 1
    patch_schedule = [
      {
        day_of_week    = "Sunday"
        start_hour_utc = 30
      }
    ]
  }

  expect_failures = [
    var.patch_schedule,
  ]
}

run "invalid_linked_server_role" {
  command = plan

  variables {
    sku_name = "Premium"
    family   = "P"
    capacity = 1
    linked_servers = [
      {
        name                        = "secondary"
        linked_redis_cache_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Cache/Redis/secondary"
        linked_redis_cache_location = "northeurope"
        server_role                 = "PrimaryReplica"
      }
    ]
  }

  expect_failures = [
    var.linked_servers,
  ]
}
