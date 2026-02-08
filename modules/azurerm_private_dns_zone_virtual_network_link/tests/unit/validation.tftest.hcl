# Validation tests for Private DNS Zone Virtual Network Link module

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
  name                = "pdns-link"
  resource_group_name = "test-rg"
}

run "invalid_private_dns_zone_name" {
  command = plan

  variables {
    private_dns_zone_name = "invalid_name"
    virtual_network_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
  }

  expect_failures = [
    var.private_dns_zone_name
  ]
}

run "invalid_virtual_network_id" {
  command = plan

  variables {
    private_dns_zone_name = "example.internal"
    virtual_network_id    = "invalid"
  }

  expect_failures = [
    var.virtual_network_id
  ]
}

run "valid_resolution_policy_default" {
  command = plan

  variables {
    private_dns_zone_name = "example.internal"
    virtual_network_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
    resolution_policy     = "Default"
  }

  assert {
    condition     = var.resolution_policy == "Default"
    error_message = "resolution_policy should accept Default."
  }
}

run "valid_resolution_policy_nxdomain_redirect" {
  command = plan

  variables {
    private_dns_zone_name = "example.internal"
    virtual_network_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
    resolution_policy     = "NxDomainRedirect"
  }

  assert {
    condition     = var.resolution_policy == "NxDomainRedirect"
    error_message = "resolution_policy should accept NxDomainRedirect."
  }
}

run "invalid_resolution_policy_recursive" {
  command = plan

  variables {
    private_dns_zone_name = "example.internal"
    virtual_network_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test"
    resolution_policy     = "Recursive"
  }

  expect_failures = [
    var.resolution_policy
  ]
}
