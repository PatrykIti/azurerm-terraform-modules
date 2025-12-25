# Diagnostic settings unit tests for Network Security Group module

mock_provider "azurerm" {
  mock_resource "azurerm_network_security_group" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-nsg"
      name = "test-nsg"
    }
  }

  mock_resource "azurerm_network_security_rule" {}

  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = [
        "NetworkSecurityGroupEvent",
        "NetworkSecurityGroupRuleCounter"
      ]
      metrics = ["AllMetrics"]
    }
  }
}

variables {
  name                = "test-nsg"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "diagnostic_settings_valid" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "nsg-logs"
        areas                      = ["event", "metrics"]
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

run "diagnostic_settings_missing_destination" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name = "missing-destination"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "diagnostic_settings_missing_eventhub_name" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                           = "eventhub-missing-name"
        eventhub_authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/ehns/authorizationRules/send"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "diagnostic_settings_invalid_destination_type" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                           = "invalid-destination-type"
        log_analytics_destination_type = "InvalidType"
        log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "diagnostic_settings_invalid_area" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "invalid-area"
        areas                      = ["invalid_area"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "diagnostic_settings_duplicate_names" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "dup-name"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      },
      {
        name                       = "dup-name"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}
