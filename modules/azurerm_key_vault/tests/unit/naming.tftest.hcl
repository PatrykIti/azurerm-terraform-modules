# Naming validation tests for Key Vault module

mock_provider "azurerm" {
  mock_resource "azurerm_key_vault" {}
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
}

run "valid_name" {
  command = plan

  variables {
    name = "kvvalidname01"
  }

  assert {
    condition     = var.name == "kvvalidname01"
    error_message = "name should accept valid Key Vault names."
  }
}

run "invalid_name" {
  command = plan

  variables {
    name = "invalid_name"
  }

  expect_failures = [
    var.name
  ]
}
