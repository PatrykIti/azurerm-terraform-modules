# Naming validation tests for Redis Cache module

mock_provider "azurerm" {
  mock_resource "azurerm_redis_cache" {}
}

variables {
  name                = "redisunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  sku_name            = "Standard"
  family              = "C"
  capacity            = 1
}

run "invalid_characters" {
  command = plan

  variables {
    name = "redis_invalid"
  }

  expect_failures = [
    var.name,
  ]
}

run "name_too_long" {
  command = plan

  variables {
    name = "redis-cache-name-that-is-way-too-long-for-azure-redis-service-extra"
  }

  expect_failures = [
    var.name,
  ]
}
