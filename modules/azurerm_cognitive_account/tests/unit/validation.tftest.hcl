# Validation tests for Cognitive Account module

mock_provider "azurerm" {
  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/cogunit"
      name = "cogunit"
    }
  }
  mock_resource "azurerm_cognitive_deployment" {}
  mock_resource "azurerm_cognitive_account_rai_policy" {}
  mock_resource "azurerm_cognitive_account_rai_blocklist" {}
  mock_resource "azurerm_cognitive_account_customer_managed_key" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                  = "cogunit"
  resource_group_name   = "test-rg"
  location              = "westeurope"
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "cogunit"
}

run "invalid_name" {
  command = plan

  variables {
    name = "a"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_kind" {
  command = plan

  variables {
    kind = "Face"
  }

  expect_failures = [
    var.kind
  ]
}

run "invalid_sku" {
  command = plan

  variables {
    sku_name = "INVALID"
  }

  expect_failures = [
    var.sku_name
  ]
}

run "network_acls_requires_custom_subdomain" {
  command = plan

  variables {
    custom_subdomain_name = null
    network_acls = {
      default_action = "Deny"
      bypass         = "AzureServices"
    }
  }

  expect_failures = [
    var.network_acls
  ]
}

run "network_acls_invalid_bypass" {
  command = plan

  variables {
    network_acls = {
      default_action = "Deny"
      bypass         = "Invalid"
    }
  }

  expect_failures = [
    var.network_acls
  ]
}

run "cmk_requires_user_assigned_identity" {
  command = plan

  variables {
    identity = {
      type = "SystemAssigned"
    }
    customer_managed_key = {
      key_vault_key_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv/keys/key"
    }
  }

  expect_failures = [
    var.customer_managed_key
  ]
}

run "openai_subresources_require_openai_kind" {
  command = plan

  variables {
    kind = "TextAnalytics"
    deployments = [
      {
        name = "deploy"
        model = {
          format = "OpenAI"
          name   = "gpt-4o"
        }
        sku = {
          name = "Standard"
        }
      }
    ]
  }

  expect_failures = [
    var.deployments
  ]
}

run "diagnostic_destination_empty_string" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name               = "diag-empty-destination"
        storage_account_id = " "
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "log_analytics_destination_type_requires_workspace" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                           = "diag-destination-type"
        storage_account_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/diagsa"
        log_analytics_destination_type = "Dedicated"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "diagnostic_requires_categories" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag-empty-categories"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}
