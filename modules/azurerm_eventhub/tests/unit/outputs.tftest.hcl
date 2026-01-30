# Output tests for Event Hub module

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

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/ehnsunit/eventhubs/ehunit"
    error_message = "Output 'id' should return the Event Hub ID."
  }

  assert {
    condition     = output.name == "ehunit"
    error_message = "Output 'name' should return the Event Hub name."
  }

  assert {
    condition     = length(output.partition_ids) == 2
    error_message = "Output 'partition_ids' should include two partitions."
  }
}
