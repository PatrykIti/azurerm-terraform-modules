# Defaults tests for Application Insights Workbook module

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

run "verify_optional_defaults" {
  command = plan

  assert {
    condition     = var.description == null
    error_message = "description should default to null when not set."
  }

  assert {
    condition     = var.category == null
    error_message = "category should default to null when not set."
  }

  assert {
    condition     = var.source_id == null
    error_message = "source_id should default to null when not set."
  }

  assert {
    condition     = var.identity == null
    error_message = "identity should default to null when not set."
  }

  assert {
    condition     = var.timeouts.create == null
    error_message = "timeouts.create should default to null when not set."
  }

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should default to an empty map."
  }
}
