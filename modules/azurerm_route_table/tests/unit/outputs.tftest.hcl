# Test outputs for the Route Table module

mock_provider "azurerm" {
  mock_resource "azurerm_route_table" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/test-rt"
      name                          = "test-rt"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      bgp_route_propagation_enabled = true
      subnets                       = []
      tags = {
        Environment = "Test"
        Module      = "RouteTable"
      }
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
  name                = "test-rt"
  resource_group_name = "test-rg"
  location            = "northeurope"
  tags = {
    Environment = "Test"
    Module      = "RouteTable"
  }
}

# Test basic outputs
run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/test-rt"
    error_message = "Output 'id' should return the route table ID"
  }

  assert {
    condition     = output.name == "test-rt"
    error_message = "Output 'name' should return the route table name"
  }

  assert {
    condition     = output.location == "northeurope"
    error_message = "Output 'location' should return the route table location"
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name"
  }
}

# Test BGP propagation output
run "verify_bgp_propagation_output" {
  command = plan

  variables {
    bgp_route_propagation_enabled = false
  }

  assert {
    condition     = output.bgp_route_propagation_enabled == false
    error_message = "Output 'bgp_route_propagation_enabled' should reflect the input value"
  }
}

# Test routes output
run "verify_routes_output" {
  command = plan

  variables {
    routes = [
      {
        name           = "route1"
        address_prefix = "10.0.0.0/16"
        next_hop_type  = "VnetLocal"
      },
      {
        name                   = "route2"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.4"
      }
    ]
  }

  assert {
    condition     = length(output.routes) == 2
    error_message = "Output 'routes' should contain all created routes"
  }

  assert {
    condition     = can(output.routes["route1"])
    error_message = "Output 'routes' should be accessible by route name"
  }

  assert {
    condition     = can(output.routes["route2"])
    error_message = "Output 'routes' should be accessible by route name"
  }
}

# Test tags output
run "verify_tags_output" {
  command = plan

  assert {
    condition     = output.tags["Environment"] == "Test"
    error_message = "Output 'tags' should return the route table tags"
  }

  assert {
    condition     = output.tags["Module"] == "RouteTable"
    error_message = "Output 'tags' should return all tags"
  }
}

# Test empty routes output
run "verify_empty_routes_output" {
  command = plan

  variables {
    routes = []
  }

  assert {
    condition     = length(output.routes) == 0
    error_message = "Output 'routes' should be empty when no routes are defined"
  }
}