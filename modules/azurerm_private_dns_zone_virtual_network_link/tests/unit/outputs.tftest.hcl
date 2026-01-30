# Output tests for Private DNS Zone Virtual Network Link module

mock_provider "azurerm" {
  mock_resource "azurerm_private_dns_zone_virtual_network_link" {
    defaults = {
      id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/example.internal/virtualNetworkLinks/pdns-link"
      name                  = "pdns-link"
      resource_group_name   = "test-rg"
      private_dns_zone_name = "example.internal"
      virtual_network_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
      registration_enabled  = true
      resolution_policy     = "Default"
      tags = {
        Environment = "Test"
      }
    }
  }
}

variables {
  name                  = "pdns-link"
  resource_group_name   = "test-rg"
  private_dns_zone_name = "example.internal"
  virtual_network_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
  registration_enabled  = true
  resolution_policy     = "Default"
  tags = {
    Environment = "Test"
  }
}

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/example.internal/virtualNetworkLinks/pdns-link"
    error_message = "Output 'id' should return the link ID."
  }

  assert {
    condition     = output.name == "pdns-link"
    error_message = "Output 'name' should return the link name."
  }

  assert {
    condition     = output.private_dns_zone_name == "example.internal"
    error_message = "Output 'private_dns_zone_name' should return the zone name."
  }

  assert {
    condition     = output.virtual_network_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
    error_message = "Output 'virtual_network_id' should return the VNet ID."
  }

  assert {
    condition     = output.registration_enabled == true
    error_message = "Output 'registration_enabled' should return the registration flag."
  }

  assert {
    condition     = output.resolution_policy == "Default"
    error_message = "Output 'resolution_policy' should return the policy."
  }

  assert {
    condition     = output.tags["Environment"] == "Test"
    error_message = "Output 'tags' should include the Environment tag."
  }
}
