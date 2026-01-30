# Output tests for Bastion Host module

mock_provider "azurerm" {
  mock_resource "azurerm_bastion_host" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/bastionHosts/bastionunit"
      name                = "bastionunit"
      location            = "northeurope"
      resource_group_name = "test-rg"
      sku                 = "Standard"
      dns_name            = "bastionunit.eastus.bastion.azure.com"
      ip_configuration = [
        {
          name                 = "ipconfig"
          subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/AzureBastionSubnet"
          public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/pip"
        }
      ]
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = ["BastionAuditLogs"]
      metrics            = ["AllMetrics"]
    }
  }
}

variables {
  name                = "bastionunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  sku                 = "Standard"

  ip_configuration = [
    {
      name                 = "ipconfig"
      subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/AzureBastionSubnet"
      public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/pip"
    }
  ]
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/bastionHosts/bastionunit"
    error_message = "Output 'id' should return the Bastion Host ID."
  }

  assert {
    condition     = output.name == "bastionunit"
    error_message = "Output 'name' should return the Bastion Host name."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.sku == "Standard"
    error_message = "Output 'sku' should return the Bastion Host SKU."
  }

  assert {
    condition     = output.dns_name == "bastionunit.eastus.bastion.azure.com"
    error_message = "Output 'dns_name' should return the Bastion Host DNS name."
  }

  assert {
    condition     = length(output.ip_configuration) == 1
    error_message = "Output 'ip_configuration' should include a single entry."
  }
}

run "verify_diagnostic_settings_skipped" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "empty-categories"
        areas                      = []
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 1
    error_message = "Diagnostic settings with no categories should be reported as skipped."
  }

  assert {
    condition     = output.diagnostic_settings_skipped[0].name == "empty-categories"
    error_message = "Skipped diagnostic settings entry should include the name."
  }
}
