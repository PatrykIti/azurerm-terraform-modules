# Default value tests for Event Hub module

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

  mock_resource "azurerm_eventhub_consumer_group" {}
  mock_resource "azurerm_eventhub_authorization_rule" {}
}

variables {
  name            = "ehunit"
  namespace_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/ehnsunit"
  partition_count = 2
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = azurerm_eventhub.eventhub.status == "Active"
    error_message = "status should default to Active."
  }

  assert {
    condition     = azurerm_eventhub.eventhub.message_retention == 1
    error_message = "message_retention should default to 1."
  }
}
