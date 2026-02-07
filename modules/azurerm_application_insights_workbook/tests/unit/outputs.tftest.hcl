# Output tests for Application Insights Workbook module

mock_provider "azurerm" {
  mock_resource "azurerm_application_insights_workbook" {
    defaults = {
      id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/workbooks/2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
      name                 = "2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
      resource_group_name  = "test-rg"
      location             = "westeurope"
      display_name         = "Workbook Unit"
      data_json            = "{\"version\":\"Notebook/1.0\",\"items\":[]}"
      storage_container_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage/blobServices/default/containers/workbook-storage"
      identity = {
        type         = "SystemAssigned"
        principal_id = "00000000-0000-0000-0000-000000000001"
        tenant_id    = "00000000-0000-0000-0000-000000000002"
        identity_ids = []
      }
    }
  }
}

variables {
  name                 = "2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
  resource_group_name  = "test-rg"
  location             = "westeurope"
  display_name         = "Workbook Unit"
  data_json            = "{\"version\":\"Notebook/1.0\",\"items\":[]}"
  storage_container_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage/blobServices/default/containers/workbook-storage"
  identity = {
    type = "SystemAssigned"
  }
}

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/workbooks/2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
    error_message = "Output 'id' should return the workbook ID."
  }

  assert {
    condition     = output.name == "2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
    error_message = "Output 'name' should return the workbook name."
  }

  assert {
    condition     = output.location == "westeurope"
    error_message = "Output 'location' should return the workbook location."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the workbook resource group."
  }

  assert {
    condition     = output.storage_container_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage/blobServices/default/containers/workbook-storage"
    error_message = "Output 'storage_container_id' should return the configured storage container ID."
  }

  assert {
    condition     = output.identity.type == "SystemAssigned"
    error_message = "Output 'identity.type' should return the identity type."
  }
}
