# Output tests for Key Vault module

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

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/kvunit"
    error_message = "Output 'id' should return the Key Vault ID."
  }

  assert {
    condition     = output.name == "kvunit"
    error_message = "Output 'name' should return the Key Vault name."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.vault_uri == "https://kvunit.vault.azure.net/"
    error_message = "Output 'vault_uri' should return the vault URI."
  }

  assert {
    condition     = length(output.keys) == 0
    error_message = "Output 'keys' should be empty when no keys are defined."
  }

  assert {
    condition     = length(output.secrets) == 0
    error_message = "Output 'secrets' should be empty when no secrets are defined."
  }
}
