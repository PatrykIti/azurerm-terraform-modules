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

run "verify_diagnostic_partner_solution_and_category_group" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                = "partner-and-group"
        partner_solution_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationsManagement/solutions/example"
        log_category_groups = ["allLogs"]
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 0
    error_message = "Supported category groups should not be skipped when partner_solution_id is used as destination."
  }
}
