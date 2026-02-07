# Validation tests for Event Hub Namespace module

mock_provider "azurerm" {
  mock_resource "azurerm_eventhub_namespace" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/ehnsunit"
      name                          = "ehnsunit"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      sku                           = "Standard"
      capacity                      = 1
      public_network_access_enabled = true
      local_authentication_enabled  = true
      minimum_tls_version           = "1.2"
    }
  }

  mock_resource "azurerm_eventhub_namespace_authorization_rule" {}
  mock_resource "azurerm_eventhub_namespace_disaster_recovery_config" {}
  mock_resource "azurerm_eventhub_namespace_customer_managed_key" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = ["OperationalLogs"]
      metrics            = ["AllMetrics"]
    }
  }
}

variables {
  name                = "ehnsunit01"
  resource_group_name = "test-rg"
  location            = "northeurope"
  sku                 = "Standard"
}

run "invalid_name" {
  command = plan

  variables {
    name = "1invalid"
  }

  expect_failures = [
    var.name
  ]
}

run "auto_inflate_requires_max" {
  command = plan

  variables {
    auto_inflate_enabled     = true
    maximum_throughput_units = null
  }

  expect_failures = [
    azurerm_eventhub_namespace.namespace
  ]
}

run "authorization_rule_requires_permissions" {
  command = plan

  variables {
    namespace_authorization_rules = [
      {
        name   = "rule1"
        manage = true
      }
    ]
  }

  expect_failures = [
    var.namespace_authorization_rules
  ]
}

run "cmk_requires_identity" {
  command = plan

  variables {
    customer_managed_key = {
      key_vault_key_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/kv/keys/key"
      ]
    }
  }

  expect_failures = [
    azurerm_eventhub_namespace_customer_managed_key.customer_managed_key
  ]
}

run "network_public_access_mismatch" {
  command = plan

  variables {
    public_network_access_enabled = false
    network_rule_set = {
      default_action                = "Deny"
      public_network_access_enabled = true
      ip_rules                      = []
      vnet_rules                    = []
    }
  }

  expect_failures = [
    azurerm_eventhub_namespace.namespace
  ]
}
