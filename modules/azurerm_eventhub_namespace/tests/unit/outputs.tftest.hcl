# Output tests for Event Hub Namespace module

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

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/ehnsunit"
    error_message = "Output 'id' should return the namespace ID."
  }

  assert {
    condition     = output.name == "ehnsunit"
    error_message = "Output 'name' should return the namespace name."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }
}
