# Defaults tests for Linux Function App module

mock_provider "azurerm" {
  mock_resource "azurerm_linux_function_app" {
    defaults = {
      id                                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/funcunit"
      name                              = "funcunit"
      location                          = "northeurope"
      resource_group_name               = "test-rg"
      default_hostname                  = "funcunit.azurewebsites.net"
      outbound_ip_addresses             = "1.1.1.1"
      outbound_ip_address_list          = ["1.1.1.1"]
      possible_outbound_ip_addresses    = "1.1.1.1,2.2.2.2"
      possible_outbound_ip_address_list = ["1.1.1.1", "2.2.2.2"]
      tags                              = {}
    }
  }

  mock_resource "azurerm_linux_function_app_slot" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "funcunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  service_plan_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/plan"
  storage_configuration = {
    account_name       = "stunit001"
    account_access_key = "fakekey"
  }
  site_configuration = {
    application_stack = {
      node_version = "20"
    }
  }
}

run "verify_https_only_default" {
  command = plan

  assert {
    condition     = azurerm_linux_function_app.linux_function_app.https_only == true
    error_message = "https_only should default to true."
  }
}

run "verify_public_network_default" {
  command = plan

  assert {
    condition     = azurerm_linux_function_app.linux_function_app.public_network_access_enabled == false
    error_message = "public_network_access_enabled should default to false."
  }
}

run "verify_logging_default" {
  command = plan

  assert {
    condition     = azurerm_linux_function_app.linux_function_app.builtin_logging_enabled == true
    error_message = "builtin_logging_enabled should default to true."
  }
}

run "verify_ftp_basic_auth_default" {
  command = plan

  assert {
    condition     = azurerm_linux_function_app.linux_function_app.ftp_publish_basic_authentication_enabled == false
    error_message = "ftp_publish_basic_authentication_enabled should default to false."
  }
}

run "verify_storage_uses_managed_identity_default" {
  command = plan

  assert {
    condition     = coalesce(azurerm_linux_function_app.linux_function_app.storage_uses_managed_identity, false) == false
    error_message = "storage_uses_managed_identity should default to false."
  }
}

run "verify_tags_default" {
  command = plan

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should be empty by default."
  }
}
