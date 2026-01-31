# Validation tests for Event Hub module

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

run "invalid_name" {
  command = plan

  variables {
    name = "bad#name"
  }

  expect_failures = [
    var.name
  ]
}

run "missing_namespace" {
  command = plan

  variables {
    namespace_id = null
  }

  expect_failures = [
    var.namespace_id
  ]
}

run "capture_missing_tokens" {
  command = plan

  variables {
    capture_description = {
      enabled  = true
      encoding = "Avro"
      destination = {
        storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/stacct"
        blob_container_name = "capture"
        archive_name_format = "{Namespace}/{EventHub}"
      }
    }
  }

  expect_failures = [
    var.capture_description
  ]
}

run "authorization_rule_requires_permissions" {
  command = plan

  variables {
    authorization_rules = [
      {
        name   = "rule1"
        manage = true
      }
    ]
  }

  expect_failures = [
    var.authorization_rules
  ]
}
