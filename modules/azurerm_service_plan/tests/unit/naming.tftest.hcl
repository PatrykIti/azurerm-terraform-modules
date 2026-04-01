# Naming validation tests for App Service Plan module

mock_provider "azurerm" {
  mock_resource "azurerm_service_plan" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/aspunit"
      name = "aspunit"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan = {
    os_type  = "Windows"
    sku_name = "B1"
  }
}

run "invalid_name_empty" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_whitespace" {
  command = plan

  variables {
    name = "   "
  }

  expect_failures = [
    var.name
  ]
}
