# Validation tests for Application Insights module

mock_provider "azurerm" {
  mock_resource "azurerm_application_insights" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "appinsunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "invalid_sampling_percentage" {
  command = plan

  variables {
    sampling_percentage = 120
  }

  expect_failures = [
    var.sampling_percentage
  ]
}

run "invalid_retention" {
  command = plan

  variables {
    retention_in_days = 7
  }

  expect_failures = [
    var.retention_in_days
  ]
}

run "invalid_daily_cap" {
  command = plan

  variables {
    daily_data_cap_in_gb = 0
  }

  expect_failures = [
    var.daily_data_cap_in_gb
  ]
}

run "api_key_missing_permissions" {
  command = plan

  variables {
    api_keys = [
      {
        name = "no-permissions"
      }
    ]
  }

  expect_failures = [
    var.api_keys
  ]
}

run "monitoring_missing_destination" {
  command = plan

  variables {
    monitoring = [
      {
        name           = "diag"
        metric_categories = ["AllMetrics"]
      }
    ]
  }

  expect_failures = [
    var.monitoring
  ]
}

run "web_test_missing_geo" {
  command = plan

  variables {
    web_tests = [
      {
        name         = "bad-webtest"
        web_test_xml = "<WebTest></WebTest>"
        geo_locations = []
      }
    ]
  }

  expect_failures = [
    var.web_tests
  ]
}
