# Output tests for Windows Function App module

mock_provider "azurerm" {
  mock_resource "azurerm_windows_function_app" {
    defaults = {
      id                             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/wfuncunit"
      name                           = "wfuncunit"
      location                       = "northeurope"
      resource_group_name            = "test-rg"
      default_hostname               = "wfuncunit.azurewebsites.net"
      outbound_ip_addresses          = "10.0.0.1,10.0.0.2"
      possible_outbound_ip_addresses = "10.0.0.3,10.0.0.4"
    }
  }

  mock_resource "azurerm_windows_function_app_slot" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "wfuncunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/plan"
  storage_configuration = {
    account_name       = "storageunit"
    account_access_key = "fakekey"
  }
  site_config = {
    application_stack = {
      dotnet_version = "v8.0"
    }
  }
  identity = {
    type = "SystemAssigned"
  }
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/wfuncunit"
    error_message = "Output 'id' should return the Function App ID."
  }

  assert {
    condition     = output.name == "wfuncunit"
    error_message = "Output 'name' should return the Function App name."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.default_hostname == "wfuncunit.azurewebsites.net"
    error_message = "Output 'default_hostname' should return the default hostname."
  }

  assert {
    condition     = output.identity.type == "SystemAssigned"
    error_message = "Output 'identity' should expose managed identity type."
  }
}
