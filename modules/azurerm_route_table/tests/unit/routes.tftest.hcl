# Test route configurations for the Route Table module

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
  name                = "test-rt"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test single route creation
run "single_route" {
  command = plan

  variables {
    routes = [
      {
        name           = "internet-route"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      }
    ]
  }

  assert {
    condition     = length(azurerm_route.routes) == 1
    error_message = "Should create exactly one route"
  }
  
  assert {
    condition     = azurerm_route.routes["internet-route"].address_prefix == "0.0.0.0/0"
    error_message = "Route address prefix should be 0.0.0.0/0"
  }
  
  assert {
    condition     = azurerm_route.routes["internet-route"].next_hop_type == "Internet"
    error_message = "Route next hop type should be Internet"
  }
}

# Test multiple routes
run "multiple_routes" {
  command = plan

  variables {
    routes = [
      {
        name           = "internet"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      },
      {
        name           = "local-vnet"
        address_prefix = "10.0.0.0/16"
        next_hop_type  = "VnetLocal"
      },
      {
        name                   = "firewall"
        address_prefix         = "192.168.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.4"
      }
    ]
  }

  assert {
    condition     = length(azurerm_route.routes) == 3
    error_message = "Should create three routes"
  }
}

# Test VirtualAppliance route
run "virtual_appliance_route" {
  command = plan

  variables {
    routes = [
      {
        name                   = "to-firewall"
        address_prefix         = "10.0.0.0/8"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "172.16.0.4"
      }
    ]
  }

  assert {
    condition     = azurerm_route.routes["to-firewall"].next_hop_in_ip_address == "172.16.0.4"
    error_message = "VirtualAppliance route should have next hop IP address"
  }
}

# Test VirtualNetworkGateway route
run "virtual_network_gateway_route" {
  command = plan

  variables {
    routes = [
      {
        name           = "to-onprem"
        address_prefix = "192.168.0.0/16"
        next_hop_type  = "VirtualNetworkGateway"
      }
    ]
  }

  assert {
    condition     = azurerm_route.routes["to-onprem"].next_hop_type == "VirtualNetworkGateway"
    error_message = "Route should use VirtualNetworkGateway as next hop"
  }
  
  assert {
    condition     = azurerm_route.routes["to-onprem"].next_hop_in_ip_address == null
    error_message = "VirtualNetworkGateway route should not have next hop IP"
  }
}

# Test None route (blackhole)
run "none_route" {
  command = plan

  variables {
    routes = [
      {
        name           = "blackhole"
        address_prefix = "1.2.3.4/32"
        next_hop_type  = "None"
      }
    ]
  }

  assert {
    condition     = azurerm_route.routes["blackhole"].next_hop_type == "None"
    error_message = "Route should use None as next hop for blackhole"
  }
}

# Test empty routes
run "empty_routes" {
  command = plan

  variables {
    routes = []
  }

  assert {
    condition     = length(azurerm_route.routes) == 0
    error_message = "No routes should be created when routes list is empty"
  }
}

# Test route names as keys
run "route_names_as_keys" {
  command = plan

  variables {
    routes = [
      {
        name           = "route-1"
        address_prefix = "10.0.0.0/16"
        next_hop_type  = "VnetLocal"
      },
      {
        name           = "route-2"
        address_prefix = "10.1.0.0/16"
        next_hop_type  = "VnetLocal"
      }
    ]
  }

  assert {
    condition     = contains(keys(azurerm_route.routes), "route-1")
    error_message = "Route should be accessible by name as key"
  }
  
  assert {
    condition     = contains(keys(azurerm_route.routes), "route-2")
    error_message = "Route should be accessible by name as key"
  }
}