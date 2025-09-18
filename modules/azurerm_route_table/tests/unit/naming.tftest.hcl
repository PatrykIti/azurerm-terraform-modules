# Test naming conventions for the Route Table module

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

# Test valid route table name with prefix
run "valid_name_with_prefix" {
  command = plan

  variables {
    name = "rt-prod-westeurope-001"
  }

  assert {
    condition     = azurerm_route_table.route_table.name == "rt-prod-westeurope-001"
    error_message = "Route table name should match the input"
  }
}

# Test valid route table name without prefix
run "valid_name_without_prefix" {
  command = plan

  variables {
    name = "myroutetable"
  }

  assert {
    condition     = azurerm_route_table.route_table.name == "myroutetable"
    error_message = "Route table name should match the input"
  }
}

# Test route table name with numbers
run "valid_name_with_numbers" {
  command = plan

  variables {
    name = "rt123"
  }

  assert {
    condition     = azurerm_route_table.route_table.name == "rt123"
    error_message = "Route table name with numbers should be valid"
  }
}

# Test route names
run "route_naming_conventions" {
  command = plan

  variables {
    name = "test-rt"
    routes = [
      {
        name           = "to-internet"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      },
      {
        name           = "to-on-premises"
        address_prefix = "192.168.0.0/16"
        next_hop_type  = "VirtualNetworkGateway"
      },
      {
        name                   = "force-to-firewall"
        address_prefix         = "10.0.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.4"
      },
      {
        name           = "blackhole-malicious-ip"
        address_prefix = "1.2.3.4/32"
        next_hop_type  = "None"
      }
    ]
  }

  assert {
    condition     = azurerm_route.routes["to-internet"].name == "to-internet"
    error_message = "Route name 'to-internet' should be preserved"
  }

  assert {
    condition     = azurerm_route.routes["to-on-premises"].name == "to-on-premises"
    error_message = "Route name 'to-on-premises' should be preserved"
  }

  assert {
    condition     = azurerm_route.routes["force-to-firewall"].name == "force-to-firewall"
    error_message = "Route name 'force-to-firewall' should be preserved"
  }

  assert {
    condition     = azurerm_route.routes["blackhole-malicious-ip"].name == "blackhole-malicious-ip"
    error_message = "Route name 'blackhole-malicious-ip' should be preserved"
  }
}

# Test route table name with hyphens and underscores
run "name_with_special_chars" {
  command = plan

  variables {
    name = "rt-prod_westeu_001"
  }

  assert {
    condition     = azurerm_route_table.route_table.name == "rt-prod_westeu_001"
    error_message = "Route table name with hyphens and underscores should be valid"
  }
}

# Test maximum length name (80 characters is Azure limit)
run "maximum_length_name" {
  command = plan

  variables {
    name = "rt-this-is-a-very-long-route-table-name-that-approaches-the-maximum-allowed"
  }

  assert {
    condition     = length(azurerm_route_table.route_table.name) <= 80
    error_message = "Route table name should not exceed 80 characters"
  }
}