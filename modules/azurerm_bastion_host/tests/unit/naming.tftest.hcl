# Naming validation tests for Bastion Host module

mock_provider "azurerm" {
  mock_resource "azurerm_bastion_host" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/bastionHosts/bastionunit"
      name                = "bastionunit"
      location            = "northeurope"
      resource_group_name = "test-rg"
      sku                 = "Basic"
      dns_name            = "bastionunit.eastus.bastion.azure.com"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "bastionunit"
  resource_group_name = "test-rg"
  location            = "northeurope"

  ip_configuration = [
    {
      name                 = "ipconfig"
      subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/AzureBastionSubnet"
      public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/pip"
    }
  ]
}

run "invalid_name_with_spaces" {
  command = plan

  variables {
    name = "invalid name"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_trailing_hyphen" {
  command = plan

  variables {
    name = "bastion-"
  }

  expect_failures = [
    var.name
  ]
}
