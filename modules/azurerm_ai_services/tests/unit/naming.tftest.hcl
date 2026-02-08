# Naming validation tests for AI Services Account module

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
}

variables {
  name                = "aiservicesunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  sku_name            = "S0"
}

run "invalid_name" {
  command = plan

  variables {
    name = "invalid_name!"
  }

  expect_failures = [
    var.name
  ]
}
