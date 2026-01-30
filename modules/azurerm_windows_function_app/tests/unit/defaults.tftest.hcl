# Defaults tests for Windows Function App module

mock_provider "azurerm" {
  mock_resource "azurerm_windows_function_app" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/wfuncunit"
      name                = "wfuncunit"
      location            = "northeurope"
      resource_group_name = "test-rg"
    }
  }

  mock_resource "azurerm_windows_function_app_slot" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                      = "wfuncunit"
  resource_group_name       = "test-rg"
  location                  = "northeurope"
  service_plan_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/plan"
  storage_account_name      = "storageunit"
  storage_account_access_key = "fakekey"
  site_config = {
    application_stack = {
      dotnet_version = "v8.0"
    }
  }
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.https_only == true
    error_message = "https_only should default to true."
  }

  assert {
    condition     = var.public_network_access_enabled == false
    error_message = "public_network_access_enabled should default to false."
  }

  assert {
    condition     = var.storage_uses_managed_identity == false
    error_message = "storage_uses_managed_identity should default to false."
  }

  assert {
    condition     = length(var.app_settings) == 0
    error_message = "app_settings should default to an empty map."
  }

  assert {
    condition     = length(var.connection_strings) == 0
    error_message = "connection_strings should default to an empty list."
  }

  assert {
    condition     = length(var.slots) == 0
    error_message = "slots should default to an empty list."
  }

  assert {
    condition     = length(var.diagnostic_settings) == 0
    error_message = "diagnostic_settings should default to an empty list."
  }
}
