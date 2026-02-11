# Naming tests for Event Hub Namespace module

mock_provider "azurerm" {
  mock_resource "azurerm_eventhub_namespace" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/ehnsunit"
      name                          = "ehnsunit"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      sku                           = "Standard"
      capacity                      = 1
      public_network_access_enabled = true
      local_authentication_enabled  = true
      minimum_tls_version           = "1.2"
    }
  }
}

variables {
  name                = "ehnsunit01"
  resource_group_name = "test-rg"
  location            = "northeurope"
  sku                 = "Standard"
}

run "naming_plan" {
  command = plan

  assert {
    condition     = azurerm_eventhub_namespace.namespace.name == var.name
    error_message = "Namespace name should match the input variable."
  }
}
