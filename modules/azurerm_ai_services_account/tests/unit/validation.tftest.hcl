# Validation tests for AI Services Account module

mock_provider "azurerm" {
  mock_resource "azurerm_ai_services" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/aiservicesunit"
      name                = "aiservicesunit"
      location            = "northeurope"
      resource_group_name = "test-rg"
      sku_name            = "S0"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = ["Audit"]
      metrics            = ["AllMetrics"]
    }
  }
}

variables {
  name                = "aiservicesunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  sku_name            = "S0"
}

run "invalid_sku_name" {
  command = plan

  variables {
    sku_name = "InvalidSku"
  }

  expect_failures = [
    var.sku_name
  ]
}

run "invalid_public_network_access" {
  command = plan

  variables {
    public_network_access = "Public"
  }

  expect_failures = [
    var.public_network_access
  ]
}

run "network_acls_requires_custom_subdomain" {
  command = plan

  variables {
    network_acls = {
      default_action = "Deny"
    }
  }

  expect_failures = [
    var.network_acls
  ]
}

run "cmk_requires_user_assigned_identity" {
  command = plan

  variables {
    customer_managed_key = {
      key_vault_key_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv/keys/key1"
    }
  }

  expect_failures = [
    var.customer_managed_key
  ]
}

run "user_assigned_identity_requires_ids" {
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
