# Defaults tests for Monitor Data Collection Endpoint module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_data_collection_endpoint" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionEndpoints/dceunit"
      name                          = "dceunit"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      public_network_access_enabled = true
      tags                          = {}
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "dceunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "verify_public_network_default" {
  command = plan

  assert {
    condition     = azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.public_network_access_enabled == true
    error_message = "public_network_access_enabled should default to true when not specified."
  }
}

run "verify_tags_default" {
  command = plan

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should be empty by default."
  }
}
