# Naming validation tests for Private DNS Zone Virtual Network Link module

mock_provider "azurerm" {
  mock_resource "azurerm_private_dns_zone_virtual_network_link" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/example.internal/virtualNetworkLinks/pdns-link"
      name                = "pdns-link"
      resource_group_name = "test-rg"
    }
  }
}

variables {
  resource_group_name   = "test-rg"
  private_dns_zone_name = "example.internal"
  virtual_network_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
}

run "invalid_name_chars" {
  command = plan

  variables {
    name = "invalid*name"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_too_long" {
  command = plan

  variables {
    name = "this-name-is-way-too-long-for-a-virtual-network-link-and-should-fail-12345678901234567890"
  }

  expect_failures = [
    var.name
  ]
}
