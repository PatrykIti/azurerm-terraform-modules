# Validation tests for Key Vault module

mock_provider "azurerm" {
  mock_resource "azurerm_key_vault" {}
  mock_resource "azurerm_key_vault_access_policy" {}
  mock_resource "azurerm_key_vault_key" {}
  mock_resource "azurerm_key_vault_secret" {}
  mock_resource "azurerm_key_vault_certificate" {}
  mock_resource "azurerm_key_vault_certificate_issuer" {}
  mock_resource "azurerm_key_vault_managed_storage_account" {}
  mock_resource "azurerm_key_vault_managed_storage_account_sas_token_definition" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "kvunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
}

run "invalid_sku" {
  command = plan

  variables {
    sku_name = "invalid"
  }

  expect_failures = [
    var.sku_name
  ]
}

run "invalid_retention" {
  command = plan

  variables {
    soft_delete_retention_days = 3
  }

  expect_failures = [
    var.soft_delete_retention_days
  ]
}

run "rbac_with_access_policies" {
  command = plan

  variables {
    rbac_authorization_enabled = true
    access_policies = [
      {
        name               = "policy"
        object_id          = "00000000-0000-0000-0000-000000000000"
        tenant_id          = "00000000-0000-0000-0000-000000000000"
        secret_permissions = ["Get"]
      }
    ]
  }

  expect_failures = [
    var.access_policies
  ]
}

run "invalid_network_acls" {
  command = plan

  variables {
    network_acls = {
      bypass         = "Invalid"
      default_action = "Block"
    }
  }

  expect_failures = [
    var.network_acls
  ]
}

run "invalid_key_type" {
  command = plan

  variables {
    keys = [
      {
        name     = "bad-key"
        key_type = "INVALID"
        key_opts = ["decrypt"]
      }
    ]
  }

  expect_failures = [
    var.keys
  ]
}

run "invalid_key_size" {
  command = plan

  variables {
    keys = [
      {
        name     = "rsa-key"
        key_type = "RSA"
        key_opts = ["decrypt"]
      }
    ]
  }

  expect_failures = [
    var.keys
  ]
}

run "invalid_secret_value" {
  command = plan

  variables {
    secrets = [
      {
        name  = "bad-secret"
        value = ""
      }
    ]
  }

  expect_failures = [
    var.secrets
  ]
}

run "invalid_certificate_policy" {
  command = plan

  variables {
    certificates = [
      {
        name = "bad-cert"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            exportable = true
            key_type   = "EC"
            reuse_key  = true
          }
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
        }
      }
    ]
  }

  expect_failures = [
    var.certificates
  ]
}

run "invalid_managed_storage_sas" {
  command = plan

  variables {
    managed_storage_sas_definitions = [
      {
        name             = "sas"
        sas_template_uri = "https://example"
        sas_type         = "service"
        validity_period  = "P30D"
      }
    ]
  }

  expect_failures = [
    var.managed_storage_sas_definitions
  ]
}

run "invalid_diagnostic_settings_destination" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name           = "diag"
        log_categories = ["AuditEvent"]
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
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law"
        log_categories             = ["InvalidCategory"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}

run "invalid_diagnostic_log_category_group" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law"
        log_category_groups        = ["invalidGroup"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}
