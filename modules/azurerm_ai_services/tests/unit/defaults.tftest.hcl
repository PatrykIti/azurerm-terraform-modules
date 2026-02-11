# Default value tests for AI Services Account module

mock_provider "azurerm" {
  mock_resource "azurerm_ai_services" {
    defaults = {
      id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/aiservicesunit"
      name                  = "aiservicesunit"
      location              = "northeurope"
      resource_group_name   = "test-rg"
      sku_name              = "S0"
      public_network_access = "Enabled"
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

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.public_network_access == "Enabled"
    error_message = "public_network_access should default to Enabled."
  }

  assert {
    condition     = var.local_authentication_enabled == true
    error_message = "local_authentication_enabled should default to true."
  }

  assert {
    condition     = var.outbound_network_access_restricted == false
    error_message = "outbound_network_access_restricted should default to false."
  }

  assert {
    condition     = length(var.diagnostic_settings) == 0
    error_message = "diagnostic_settings should default to an empty list."
  }

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should default to an empty map."
  }
}
