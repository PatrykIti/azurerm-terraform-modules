# Validation tests for Monitor Private Link Scope module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_private_link_scope" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/privateLinkScopes/amplsunit"
      name = "amplsunit"
    }
  }

  mock_resource "azurerm_monitor_private_link_scoped_service" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "amplsunit"
  resource_group_name = "test-rg"
}

run "invalid_ingestion_access_mode" {
  command = plan

  variables {
    ingestion_access_mode = "Invalid"
  }

  expect_failures = [
    var.ingestion_access_mode
  ]
}

run "invalid_query_access_mode" {
  command = plan

  variables {
    query_access_mode = "Invalid"
  }

  expect_failures = [
    var.query_access_mode
  ]
}

run "scoped_services_duplicate_names" {
  command = plan

  variables {
    scoped_services = [
      {
        name               = "service"
        linked_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/ws"
      },
      {
        name               = "service"
        linked_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/appi"
      }
    ]
  }

  expect_failures = [
    var.scoped_services
  ]
}

run "scoped_services_invalid_resource_id" {
  command = plan

  variables {
    scoped_services = [
      {
        name               = "service"
        linked_resource_id = "not-a-resource-id"
      }
    ]
  }

  expect_failures = [
    var.scoped_services
  ]
}

run "monitoring_missing_destination" {
  command = plan

  variables {
    monitoring = [
      {
        name           = "diag"
        log_categories = ["AuditEvent"]
      }
    ]
  }

  expect_failures = [
    var.monitoring
  ]
}
