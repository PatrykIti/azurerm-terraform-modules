# Output tests for Application Insights module

mock_provider "azurerm" {
  mock_resource "azurerm_application_insights" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/appins"
      name                = "appins"
      location            = "northeurope"
      resource_group_name = "test-rg"
      application_type    = "web"
      app_id              = "00000000-0000-0000-0000-000000000000"
      instrumentation_key = "00000000-0000-0000-0000-000000000000"
      connection_string   = "InstrumentationKey=00000000-0000-0000-0000-000000000000"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
  mock_resource "azurerm_application_insights_api_key" {}
  mock_resource "azurerm_application_insights_analytics_item" {}
  mock_resource "azurerm_application_insights_web_test" {}
  mock_resource "azurerm_application_insights_standard_web_test" {}
  mock_resource "azurerm_application_insights_smart_detection_rule" {}
}

variables {
  name                = "appinsunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/appins"
    error_message = "Output 'id' should return the Application Insights ID."
  }

  assert {
    condition     = output.name == "appinsunit"
    error_message = "Output 'name' should return the Application Insights name."
  }

  assert {
    condition     = output.application_type == "web"
    error_message = "Output 'application_type' should return the Application Insights type."
  }

  assert {
    condition     = output.app_id == "00000000-0000-0000-0000-000000000000"
    error_message = "Output 'app_id' should return the Application Insights app ID."
  }
}
