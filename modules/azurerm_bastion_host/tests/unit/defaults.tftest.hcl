# Default value tests for Bastion Host module

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

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.sku == "Basic"
    error_message = "sku should default to Basic."
  }

  assert {
    condition     = var.copy_paste_enabled == true
    error_message = "copy_paste_enabled should default to true."
  }

  assert {
    condition     = var.file_copy_enabled == false
    error_message = "file_copy_enabled should default to false."
  }

  assert {
    condition     = var.ip_connect_enabled == false
    error_message = "ip_connect_enabled should default to false."
  }

  assert {
    condition     = var.shareable_link_enabled == false
    error_message = "shareable_link_enabled should default to false."
  }

  assert {
    condition     = var.tunneling_enabled == false
    error_message = "tunneling_enabled should default to false."
  }

  assert {
    condition     = var.session_recording_enabled == false
    error_message = "session_recording_enabled should default to false."
  }

  assert {
    condition     = var.kerberos_enabled == false
    error_message = "kerberos_enabled should default to false."
  }

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should default to an empty map."
  }
}
