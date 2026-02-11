# Naming tests for Cognitive Account module

mock_provider "azurerm" {
  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/cogunit"
      name = "cogunit"
    }
  }
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

run "valid_name" {
  command = plan

  variables {
    name = "cog-unit_01"
  }
}
