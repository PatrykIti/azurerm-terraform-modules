# Validation tests for Log Analytics Workspace module

mock_provider "azurerm" {
  mock_resource "azurerm_log_analytics_workspace" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "lawunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "invalid_retention" {
  command = plan

  variables {
    workspace = {
      retention_in_days = 6
    }
  }

  expect_failures = [
    var.workspace
  ]
}

run "invalid_daily_quota" {
  command = plan

  variables {
    workspace = {
      daily_quota_gb = 0
    }
  }

  expect_failures = [
    var.workspace
  ]
}

run "invalid_reservation_capacity" {
  command = plan

  variables {
    workspace = {
      reservation_capacity_in_gb_per_day = 100
    }
  }

  expect_failures = [
    var.workspace
  ]
}

run "invalid_sku" {
  command = plan

  variables {
    workspace = {
      sku = "InvalidSku"
    }
  }

  expect_failures = [
    var.workspace
  ]
}

run "identity_missing_user_assigned_ids" {
  command = plan

  variables {
    identity = {
      type = "UserAssigned"
    }
  }

  expect_failures = [
    var.identity
  ]
}

run "diagnostic_settings_missing_destination" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name           = "diag"
        log_categories = ["Audit"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "diagnostic_settings_missing_categories" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag-no-categories"
        storage_account_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
        partner_solution_id        = null
        log_analytics_workspace_id = null
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "diagnostic_settings_blank_destination_id" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name               = "diag-blank-destination"
        log_categories     = ["Audit"]
        storage_account_id = "   "
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "diagnostic_settings_invalid_log_category" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag-invalid-log-category"
        storage_account_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
        log_categories             = ["InvalidCategory"]
        log_analytics_workspace_id = null
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "diagnostic_settings_invalid_metric_category" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                           = "diag-invalid-metric-category"
        storage_account_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
        metric_categories              = ["InvalidMetricCategory"]
        partner_solution_id            = null
        eventhub_name                  = null
        eventhub_authorization_rule_id = null
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "diagnostic_settings_invalid_log_category_group" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                = "diag-invalid-log-group"
        storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
        log_category_groups = ["invalidGroup"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "cluster_cmk_missing_target" {
  command = plan

  variables {
    features = {
      cluster_customer_managed_keys = [
        {
          name             = "cmk"
          key_vault_key_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv/keys/key"
        }
      ]
    }
  }

  expect_failures = [
    var.features
  ]
}
