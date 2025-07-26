# Test variable validation for the Route Table module

mock_provider "azurerm" {
  mock_resource "azurerm_route_table" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/test-rt"
      name                          = "test-rt"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      bgp_route_propagation_enabled = true
    }
  }
  
  mock_resource "azurerm_route" {
    defaults = {
      id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/test-rt/routes/test-route"
      name                   = "test-route"
      resource_group_name    = "test-rg"
      route_table_name       = "test-rt"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VnetLocal"
      next_hop_in_ip_address = null
    }
  }
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test invalid next hop type
run "invalid_route_next_hop_type" {
  command = plan

  variables {
    name = "test-rt"
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

# Test missing next hop IP for VirtualAppliance
run "missing_next_hop_ip_for_virtual_appliance" {
  command = plan

  variables {
    name = "test-rt"
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

# Test invalid next hop IP when not VirtualAppliance
run "invalid_next_hop_ip_for_non_virtual_appliance" {
  command = plan

  variables {
    name = "test-rt"
    routes = [
      {
        name                   = "invalid-ip"
        address_prefix         = "10.0.0.0/16"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = "10.0.0.1" # Should be null for Internet
      }
    ]
  }

  expect_failures = [
    var.routes
  ]
}

# Test invalid IP address format
run "invalid_ip_address_format" {
  command = plan

  variables {
    name = "test-rt"
    routes = [
      {
        name                   = "bad-ip"
        address_prefix         = "10.0.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "not-an-ip"
      }
    ]
  }

  expect_failures = [
    var.routes
  ]
}

# Test invalid CIDR format
run "invalid_cidr_format" {
  command = plan

  variables {
    name = "test-rt"
    routes = [
      {
        name           = "bad-cidr"
        address_prefix = "10.0.0.0"  # Missing CIDR notation
        next_hop_type  = "VnetLocal"
      }
    ]
  }

  expect_failures = [
    var.routes
  ]
}

# Test duplicate route names
run "duplicate_route_names" {
  command = plan

  variables {
    name = "test-rt"
    routes = [
      {
        name           = "duplicate-name"
        address_prefix = "10.0.0.0/16"
        next_hop_type  = "VnetLocal"
      },
      {
        name           = "duplicate-name"
        address_prefix = "10.1.0.0/16"
        next_hop_type  = "VnetLocal"
      }
    ]
  }

  expect_failures = [
    var.routes
  ]
}