# Defaults tests for Monitor Private Link Scope module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_private_link_scope" {
    defaults = {
      id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/privateLinkScopes/amplsunit"
      name                  = "amplsunit"
      resource_group_name   = "test-rg"
      ingestion_access_mode = "PrivateOnly"
      query_access_mode     = "PrivateOnly"
      tags                  = {}
    }
  }

  mock_resource "azurerm_monitor_private_link_scoped_service" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "amplsunit"
  resource_group_name = "test-rg"
}

run "verify_access_defaults" {
  command = plan

  assert {
    condition     = azurerm_monitor_private_link_scope.monitor_private_link_scope.ingestion_access_mode == "PrivateOnly"
    error_message = "ingestion_access_mode should default to PrivateOnly when not specified."
  }

  assert {
    condition     = azurerm_monitor_private_link_scope.monitor_private_link_scope.query_access_mode == "PrivateOnly"
    error_message = "query_access_mode should default to PrivateOnly when not specified."
  }
}

run "verify_tags_default" {
  command = plan

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should be empty by default."
  }
}
