# Default value tests for Event Hub Namespace module

mock_provider "azurerm" {
  mock_resource "azurerm_eventhub_namespace" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/ehnsunit"
      name                          = "ehnsunit"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      sku                           = "Standard"
      capacity                      = 1
      auto_inflate_enabled          = false
      maximum_throughput_units      = 0
      public_network_access_enabled = true
      local_authentication_enabled  = true
      minimum_tls_version           = "1.2"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = ["OperationalLogs"]
      metrics            = ["AllMetrics"]
    }
  }
}

variables {
  name                = "ehnsunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  sku                 = "Standard"
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = azurerm_eventhub_namespace.namespace.public_network_access_enabled == true
    error_message = "public_network_access_enabled should default to true."
  }

  assert {
    condition     = azurerm_eventhub_namespace.namespace.local_authentication_enabled == true
    error_message = "local_authentication_enabled should default to true."
  }

  assert {
    condition     = azurerm_eventhub_namespace.namespace.minimum_tls_version == "1.2"
    error_message = "minimum_tls_version should default to 1.2."
  }

  assert {
    condition     = azurerm_eventhub_namespace.namespace.auto_inflate_enabled == false
    error_message = "auto_inflate_enabled should default to false."
  }
}
