# Diagnostic settings unit tests for Storage Account module

mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
      name                      = "testsa"
      primary_blob_endpoint     = "https://testsa.blob.core.windows.net/"
      primary_location          = "northeurope"
      primary_access_key        = "mock-access-key"
      secondary_access_key      = "mock-secondary-key"
      primary_connection_string = "DefaultEndpointsProtocol=https;AccountName=testsa;AccountKey=mock-key;EndpointSuffix=core.windows.net"
      min_tls_version           = "TLS1_2"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = ["StorageRead", "StorageWrite", "StorageDelete"]
      metrics            = ["Transaction", "Capacity"]
    }
  }
}

variables {
  name                = "testsa"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "diagnostic_settings_valid" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "storage-all"
        scope                      = "storage_account"
        areas                      = ["read", "transaction"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 0
    error_message = "No diagnostic settings should be skipped when categories are available."
  }
}

run "diagnostic_settings_skips_empty_categories" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "empty-categories"
        log_categories             = []
        metric_categories          = []
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 1
    error_message = "Entries with no categories should be reported as skipped."
  }

  assert {
    condition     = output.diagnostic_settings_skipped[0].name == "empty-categories"
    error_message = "Skipped entry should include the original name."
  }
}
