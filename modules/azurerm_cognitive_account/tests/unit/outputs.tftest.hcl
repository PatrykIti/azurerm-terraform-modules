# Outputs tests for Cognitive Account module

mock_provider "azurerm" {
  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/cogunit"
      name                          = "cogunit"
      location                      = "westeurope"
      resource_group_name           = "test-rg"
      kind                          = "OpenAI"
      sku_name                      = "S0"
      endpoint                      = "https://cogunit.openai.azure.com/"
      custom_subdomain_name         = "cogunit"
      public_network_access_enabled = true
      primary_access_key            = "primary"
      secondary_access_key          = "secondary"
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
  local_auth_enabled    = true
}

run "outputs_present" {
  command = apply

  assert {
    condition     = output.id != null
    error_message = "id output should be set."
  }

  assert {
    condition     = output.endpoint != null
    error_message = "endpoint output should be set."
  }

  assert {
    condition     = output.primary_access_key != null
    error_message = "primary_access_key should be set when local auth is enabled."
  }
}
