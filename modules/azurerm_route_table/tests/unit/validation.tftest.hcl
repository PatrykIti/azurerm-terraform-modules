# tests/unit/validation.tftest.hcl

mock_provider "azurerm" {}

run "invalid_route_next_hop_type" {
  command = plan

  variables {
    name                = "test-rt"
    resource_group_name = "test-rg"
    location            = "northeurope"
    routes = [
      {
        name           = "invalid-hop"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "InvalidHopType"
      }
    ]
  }

  expect_failures = [
    var.routes
  ]
}

run "missing_next_hop_ip_for_virtual_appliance" {
  command = plan

  variables {
    name                = "test-rt"
    resource_group_name = "test-rg"
    location            = "northeurope"
    routes = [
      {
        name           = "missing-ip"
        address_prefix = "10.0.0.0/16"
        next_hop_type  = "VirtualAppliance"
        # next_hop_in_ip_address is missing
      }
    ]
  }

  expect_failures = [
    var.routes
  ]
}