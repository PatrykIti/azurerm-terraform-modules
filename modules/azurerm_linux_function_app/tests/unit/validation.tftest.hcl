# Validation tests for Linux Function App module

mock_provider "azurerm" {
  mock_resource "azurerm_linux_function_app" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "funcunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/plan"
  storage_configuration = {
    account_name       = "stunit001"
    account_access_key = "fakekey"
  }
  site_configuration = {
    application_stack = {
      node_version = "20"
    }
  }
}

run "storage_managed_identity_requires_identity" {
  command = plan

  variables {
    storage_configuration = {
      account_name          = "stunit001"
      uses_managed_identity = true
    }
  }

  expect_failures = [
    var.storage_configuration
  ]
}

run "auth_settings_conflict" {
  command = plan

  variables {
    auth_settings = {
      enabled = true
    }
    auth_settings_v2 = {
      auth_enabled = true
    }
  }

  expect_failures = [
    var.auth_settings
  ]
}

run "invalid_application_stack" {
  command = plan

  variables {
    site_configuration = {
      application_stack = {
        node_version   = "20"
        python_version = "3.11"
      }
    }
  }

  expect_failures = [
    var.site_configuration
  ]
}

run "client_certificate_mode_without_enabled" {
  command = plan

  variables {
    access_configuration = {
      client_certificate_mode = "Required"
    }
  }

  expect_failures = [
    var.access_configuration
  ]
}
