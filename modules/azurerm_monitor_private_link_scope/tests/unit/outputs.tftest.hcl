# Output tests for Monitor Private Link Scope module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_private_link_scope" {
    defaults = {
      id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/privateLinkScopes/amplsunit"
      name                  = "amplsunit"
      resource_group_name   = "test-rg"
      ingestion_access_mode = "PrivateOnly"
      query_access_mode     = "PrivateOnly"
      tags = {
        Environment = "Test"
        Module      = "AMPLS"
      }
    }
  }

  mock_resource "azurerm_monitor_private_link_scoped_service" {
    defaults = {
      id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/privateLinkScopes/amplsunit/scopedResources/scopedservice1"
      name               = "scopedservice1"
      scope_name         = "amplsunit"
      linked_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/ws"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "amplsunit"
  resource_group_name = "test-rg"
  scoped_services = [
    {
      name               = "scopedservice1"
      linked_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/ws"
    }
  ]
  tags = {
    Environment = "Test"
    Module      = "AMPLS"
  }
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/privateLinkScopes/amplsunit"
    error_message = "Output 'id' should return the AMPLS ID."
  }

  assert {
    condition     = output.name == "amplsunit"
    error_message = "Output 'name' should return the AMPLS name."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.scoped_service_ids["scopedservice1"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/privateLinkScopes/amplsunit/scopedResources/scopedservice1"
    error_message = "Output 'scoped_service_ids' should include the scoped service ID."
  }
}

run "verify_tags_output" {
  command = plan

  assert {
    condition     = output.tags["Environment"] == "Test"
    error_message = "Output 'tags' should include Environment tag."
  }

  assert {
    condition     = output.tags["Module"] == "AMPLS"
    error_message = "Output 'tags' should include Module tag."
  }
}
