# Defaults tests for Application Insights module

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
}

variables {
  name                = "appinsunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.application_type == "web"
    error_message = "application_type should default to web."
  }

  assert {
    condition     = var.internet_ingestion_enabled == true
    error_message = "internet_ingestion_enabled should default to true."
  }

  assert {
    condition     = var.internet_query_enabled == true
    error_message = "internet_query_enabled should default to true."
  }

  assert {
    condition     = var.local_authentication_disabled == false
    error_message = "local_authentication_disabled should default to false."
  }

  assert {
    condition     = var.disable_ip_masking == false
    error_message = "disable_ip_masking should default to false."
  }

  assert {
    condition     = var.daily_data_cap_notifications_disabled == false
    error_message = "daily_data_cap_notifications_disabled should default to false."
  }
}
