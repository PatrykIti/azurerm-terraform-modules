# Defaults tests for Key Vault module

mock_provider "azurerm" {
  mock_resource "azurerm_key_vault" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/kvunit"
      name                = "kvunit"
      location            = "northeurope"
      resource_group_name = "test-rg"
      tenant_id           = "00000000-0000-0000-0000-000000000000"
      sku_name            = "standard"
      vault_uri           = "https://kvunit.vault.azure.net/"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "kvunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.sku_name == "standard"
    error_message = "sku_name should default to standard."
  }

  assert {
    condition     = var.rbac_authorization_enabled == true
    error_message = "rbac_authorization_enabled should default to true."
  }

  assert {
    condition     = var.public_network_access_enabled == false
    error_message = "public_network_access_enabled should default to false."
  }

  assert {
    condition     = var.purge_protection_enabled == true
    error_message = "purge_protection_enabled should default to true."
  }

  assert {
    condition     = var.soft_delete_retention_days == 90
    error_message = "soft_delete_retention_days should default to 90."
  }

  assert {
    condition     = var.network_acls == null
    error_message = "network_acls should default to null."
  }
}
