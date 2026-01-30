# Defaults tests for Private DNS Zone module

mock_provider "azurerm" {
  mock_resource "azurerm_private_dns_zone" {
    defaults = {
      id                                             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/example.internal"
      name                                           = "example.internal"
      resource_group_name                            = "test-rg"
      number_of_record_sets                          = 1
      max_number_of_virtual_network_links            = 1000
      max_number_of_virtual_network_links_with_registration = 100
      tags                                           = {}
    }
  }
}

variables {
  name                = "example.internal"
  resource_group_name = "test-rg"
}

run "verify_defaults" {
  command = plan

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should default to an empty map."
  }

  assert {
    condition     = var.soa_record == null
    error_message = "soa_record should be null by default."
  }
}
