# Naming and uniqueness validation tests for Windows Function App module

mock_provider "azurerm" {
  mock_resource "azurerm_windows_function_app" {}
  mock_resource "azurerm_windows_function_app_slot" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "wfuncunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/plan"
  storage_configuration = {
    account_name       = "storageunit"
    account_access_key = "fakekey"
  }
  site_config = {
    application_stack = {
      dotnet_version = "v8.0"
    }
  }
}

run "duplicate_slot_names" {
  command = plan

  variables {
    slots = [
      {
        name = "staging"
        site_config = {
          application_stack = {
            dotnet_version = "v8.0"
          }
        }
      },
      {
        name = "staging"
        site_config = {
          application_stack = {
            dotnet_version = "v8.0"
          }
        }
      }
    ]
  }

  expect_failures = [
    var.slots
  ]
}

run "duplicate_connection_string_names" {
  command = plan

  variables {
    application_configuration = {
      connection_strings = [
        { name = "cs1", type = "Custom", value = "value1" },
        { name = "cs1", type = "Custom", value = "value2" }
      ]
    }
  }

  expect_failures = [
    var.application_configuration
  ]
}
