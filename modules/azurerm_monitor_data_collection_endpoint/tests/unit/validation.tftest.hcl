# Validation tests for Monitor Data Collection Endpoint module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_data_collection_endpoint" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionEndpoints/dceunit"
      name = "dceunit"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "dceunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "monitoring_missing_destination" {
  command = plan

  variables {
    monitoring = [
      {
        name           = "diag"
        log_categories = ["AuditLogs"]
      }
    ]
  }

  expect_failures = [
    var.monitoring
  ]
}

run "monitoring_eventhub_without_name" {
  command = plan

  variables {
    monitoring = [
      {
        name                           = "diag"
        log_categories                 = ["AuditLogs"]
        eventhub_authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/ns/authorizationRules/rule"
      }
    ]
  }

  expect_failures = [
    var.monitoring
  ]
}

run "monitoring_invalid_destination_type" {
  command = plan

  variables {
    monitoring = [
      {
        name                           = "diag"
        log_categories                 = ["AuditLogs"]
        log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/ws"
        log_analytics_destination_type = "Invalid"
      }
    ]
  }

  expect_failures = [
    var.monitoring
  ]
}

run "monitoring_duplicate_names" {
  command = plan

  variables {
    monitoring = [
      {
        name                       = "diag"
        log_categories             = ["AuditLogs"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/ws"
      },
      {
        name                       = "diag"
        metric_categories          = ["AllMetrics"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/ws"
      }
    ]
  }

  expect_failures = [
    var.monitoring
  ]
}
