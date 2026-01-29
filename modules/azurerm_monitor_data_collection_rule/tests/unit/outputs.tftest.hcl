# Output tests for Monitor Data Collection Rule module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_data_collection_rule" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionRules/dcrunit"
      name                = "dcrunit"
      location            = "northeurope"
      resource_group_name = "test-rg"
      immutable_id        = "00000000-0000-0000-0000-000000000000"
      tags = {
        Environment = "Test"
        Module      = "DCR"
      }
    }
  }

  mock_resource "azurerm_monitor_data_collection_rule_association" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "dcrunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  destinations = {
    log_analytics = [
      {
        name                  = "log-analytics"
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/ws"
      }
    ]
  }
  data_flows = [
    {
      streams      = ["Microsoft-Perf"]
      destinations = ["log-analytics"]
    }
  ]
  tags = {
    Environment = "Test"
    Module      = "DCR"
  }
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionRules/dcrunit"
    error_message = "Output 'id' should return the rule ID."
  }

  assert {
    condition     = output.name == "dcrunit"
    error_message = "Output 'name' should return the rule name."
  }

  assert {
    condition     = output.location == "northeurope"
    error_message = "Output 'location' should return the rule location."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }
}

run "verify_tags_output" {
  command = plan

  assert {
    condition     = output.tags["Environment"] == "Test"
    error_message = "Output 'tags' should include Environment tag."
  }

  assert {
    condition     = output.tags["Module"] == "DCR"
    error_message = "Output 'tags' should include Module tag."
  }
}
