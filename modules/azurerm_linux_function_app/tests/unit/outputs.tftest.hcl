# Output tests for Linux Function App module

mock_provider "azurerm" {
  mock_resource "azurerm_linux_function_app" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/funcunit"
      name                          = "funcunit"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      default_hostname              = "funcunit.azurewebsites.net"
      outbound_ip_addresses         = "1.1.1.1"
      outbound_ip_address_list      = ["1.1.1.1"]
      possible_outbound_ip_addresses = "1.1.1.1,2.2.2.2"
      possible_outbound_ip_address_list = ["1.1.1.1", "2.2.2.2"]
      tags = {
        Environment = "Test"
      }
      identity = [{
        principal_id = "00000000-0000-0000-0000-000000000000"
        tenant_id    = "11111111-1111-1111-1111-111111111111"
        type         = "SystemAssigned"
      }]
    }
  }

  mock_resource "azurerm_linux_function_app_slot" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = ["FunctionAppLogs"]
      metrics            = ["AllMetrics"]
    }
  }
}

variables {
  name                = "funcunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/plan"
  storage_account_name        = "stunit001"
  storage_account_access_key  = "fakekey"
  site_config = {
    application_stack = {
      node_version = "20"
    }
  }
  tags = {
    Environment = "Test"
  }
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/funcunit"
    error_message = "Output 'id' should return the Function App ID."
  }

  assert {
    condition     = output.name == "funcunit"
    error_message = "Output 'name' should return the Function App name."
  }

  assert {
    condition     = output.location == "northeurope"
    error_message = "Output 'location' should return the Function App location."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.default_hostname == "funcunit.azurewebsites.net"
    error_message = "Output 'default_hostname' should return the default hostname."
  }
}

run "verify_empty_slots" {
  command = plan

  assert {
    condition     = length(output.slots) == 0
    error_message = "slots output should be empty when no slots are configured."
  }
}

run "verify_tags_output" {
  command = plan

  assert {
    condition     = output.tags["Environment"] == "Test"
    error_message = "Output 'tags' should include Environment tag."
  }
}
