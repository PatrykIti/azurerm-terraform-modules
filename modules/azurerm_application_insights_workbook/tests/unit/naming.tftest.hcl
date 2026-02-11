# Naming validation tests for Application Insights Workbook module

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

run "invalid_name_not_uuid" {
  command = plan

  variables {
    name = "invalid-name"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_missing_hyphens" {
  command = plan

  variables {
    name = "2f9c2f593f8b4d8b8a2c1d9b3b2a0f01"
  }

  expect_failures = [
    var.name
  ]
}
