# Naming tests for Event Hub module

mock_provider "azurerm" {
  mock_resource "azurerm_eventhub" {
    defaults = {
      id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/ehnsunit/eventhubs/ehunit"
      name              = "ehunit"
      status            = "Active"
      partition_count   = 2
      message_retention = 1
      partition_ids     = ["0", "1"]
    }
  }
}

variables {
  name            = "ehunit"
  namespace_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/ehnsunit"
  partition_count = 2
}

run "naming_plan" {
  command = plan

  assert {
    condition     = azurerm_eventhub.eventhub.name == var.name
    error_message = "Event Hub name should match the input variable."
  }
}
