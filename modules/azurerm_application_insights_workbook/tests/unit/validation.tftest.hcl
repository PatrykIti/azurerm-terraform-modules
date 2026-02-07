# Validation tests for Application Insights Workbook module

mock_provider "azurerm" {
  mock_resource "azurerm_application_insights_workbook" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/workbooks/2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
      name                = "2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
      resource_group_name = "test-rg"
      location            = "westeurope"
      display_name        = "Workbook Unit"
      data_json           = "{\"version\":\"Notebook/1.0\",\"items\":[]}"
    }
  }
}

variables {
  name                = "2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
  resource_group_name = "test-rg"
  location            = "westeurope"
  display_name        = "Workbook Unit"
  data_json           = "{\"version\":\"Notebook/1.0\",\"items\":[]}"
}

run "invalid_display_name_empty" {
  command = plan

  variables {
    display_name = ""
  }

  expect_failures = [
    var.display_name
  ]
}

run "invalid_data_json" {
  command = plan

  variables {
    data_json = "{not-json"
  }

  expect_failures = [
    var.data_json
  ]
}

run "invalid_category" {
  command = plan

  variables {
    category = "invalid-category"
  }

  expect_failures = [
    var.category
  ]
}

run "invalid_source_id" {
  command = plan

  variables {
    source_id = "not-a-resource-id"
  }

  expect_failures = [
    var.source_id
  ]
}

run "valid_storage_container_id" {
  command = plan

  variables {
    storage_container_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage/blobServices/default/containers/workbook-storage"
    identity = {
      type = "SystemAssigned"
    }
  }

  assert {
    condition     = var.storage_container_id != null
    error_message = "storage_container_id should be accepted when it is a valid storage container resource ID."
  }
}

run "invalid_storage_container_id" {
  command = plan

  variables {
    storage_container_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
    identity = {
      type = "SystemAssigned"
    }
  }

  expect_failures = [
    var.storage_container_id
  ]
}

run "invalid_identity_type" {
  command = plan

  variables {
    identity = {
      type = "InvalidType"
    }
  }

  expect_failures = [
    var.identity
  ]
}

run "missing_identity_ids" {
  command = plan

  variables {
    identity = {
      type = "UserAssigned"
    }
  }

  expect_failures = [
    var.identity
  ]
}

run "identity_ids_without_user_assigned" {
  command = plan

  variables {
    identity = {
      type         = "SystemAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test"]
    }
  }

  expect_failures = [
    azurerm_application_insights_workbook.application_insights_workbook
  ]
}
