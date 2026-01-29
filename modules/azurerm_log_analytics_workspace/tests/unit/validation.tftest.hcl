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
    retention_in_days = 6
  }

  expect_failures = [
    var.retention_in_days
  ]
}

run "invalid_daily_quota" {
  command = plan

  variables {
    daily_quota_gb = 0
  }

  expect_failures = [
    var.daily_quota_gb
  ]
}

run "invalid_reservation_capacity" {
  command = plan

  variables {
    reservation_capacity_in_gb_per_day = 100
  }

  expect_failures = [
    var.reservation_capacity_in_gb_per_day
  ]
}

run "invalid_sku" {
  command = plan

  variables {
    sku = "InvalidSku"
  }

  expect_failures = [
    var.sku
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

run "monitoring_missing_destination" {
  command = plan

  variables {
    monitoring = [
      {
        name           = "diag"
        log_categories = ["Audit"]
      }
    ]
  }

  expect_failures = [
    var.monitoring
  ]
}

run "cluster_cmk_missing_target" {
  command = plan

  variables {
    cluster_customer_managed_keys = [
      {
        name             = "cmk"
        key_vault_key_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv/keys/key"
      }
    ]
  }

  expect_failures = [
    var.cluster_customer_managed_keys
  ]
}
