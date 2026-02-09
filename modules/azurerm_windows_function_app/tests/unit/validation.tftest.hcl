# Validation tests for Windows Function App module

mock_provider "azurerm" {
  mock_resource "azurerm_windows_function_app" {}
  mock_resource "azurerm_windows_function_app_slot" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "wfuncunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/plan"
  storage_configuration = {
    account_name       = "storageunit"
    account_access_key = "fakekey"
  }
  site_config = {
    application_stack = {
      dotnet_version = "v8.0"
    }
  }
}

run "managed_identity_requires_no_access_key" {
  command = plan

  variables {
    storage_configuration = {
      account_name          = "storageunit"
      account_access_key    = "fakekey"
      uses_managed_identity = true
    }
    identity = {
      type = "SystemAssigned"
    }
  }

  expect_failures = [
    var.storage_configuration
  ]
}

run "managed_identity_requires_identity" {
  command = plan

  variables {
    storage_configuration = {
      account_name          = "storageunit"
      account_access_key    = null
      uses_managed_identity = true
    }
  }

  expect_failures = [
    var.storage_configuration
  ]
}

run "auth_settings_mutually_exclusive" {
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

run "client_certificate_mode_requires_enabled" {
  command = plan

  variables {
    access_configuration = {
      client_certificate_mode    = "Required"
      client_certificate_enabled = false
    }
  }

  expect_failures = [
    var.access_configuration
  ]
}

run "application_stack_multiple_runtimes" {
  command = plan

  variables {
    site_config = {
      application_stack = {
        dotnet_version = "v8.0"
        node_version   = "~18"
      }
    }
  }

  expect_failures = [
    var.site_config
  ]
}

run "invalid_minimum_tls_version" {
  command = plan

  variables {
    site_config = {
      minimum_tls_version = "2.0"
      application_stack = {
        dotnet_version = "v8.0"
      }
    }
  }

  expect_failures = [
    var.site_config
  ]
}

run "diagnostic_requires_explicit_categories" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "invalid_diagnostic_log_category" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
        log_categories             = ["NotSupportedCategory"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "valid_explicit_diagnostic_categories" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
        log_categories             = ["FunctionAppLogs"]
        metric_categories          = ["AllMetrics"]
      }
    ]
  }
}
