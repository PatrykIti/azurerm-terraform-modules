# Defaults tests for Private DNS Zone Virtual Network Link module

mock_provider "azurerm" {
  mock_resource "azurerm_private_dns_zone_virtual_network_link" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/example.internal/virtualNetworkLinks/pdns-link"
      name                = "pdns-link"
      resource_group_name = "test-rg"
      private_dns_zone_name = "example.internal"
      virtual_network_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
      registration_enabled = false
      resolution_policy    = "Default"
      tags                 = {}
    }
  }
}

variables {
  name                  = "pdns-link"
  resource_group_name   = "test-rg"
  private_dns_zone_name = "example.internal"
  virtual_network_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = var.registration_enabled == false
    error_message = "registration_enabled should default to false."
  }

  assert {
    condition     = var.resolution_policy == null
    error_message = "resolution_policy should default to null."
  }

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should default to an empty map."
  }
}
