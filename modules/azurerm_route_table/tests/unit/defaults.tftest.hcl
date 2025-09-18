# Test default settings for the Route Table module

mock_provider "azurerm" {
  mock_resource "azurerm_route_table" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/test-rt"
      name                          = "test-rt"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      bgp_route_propagation_enabled = true
      subnets                       = []
      tags                          = {}
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

# Test default BGP propagation setting
run "verify_bgp_propagation_default" {
  command = plan

  assert {
    condition     = azurerm_route_table.route_table.bgp_route_propagation_enabled == true
    error_message = "BGP route propagation should be enabled by default"
  }
}

# Test default routes (should be empty)
run "verify_default_routes" {
  command = plan

  assert {
    condition     = length(var.routes) == 0
    error_message = "Routes should be empty by default"
  }
}

# Test default tags (should be empty)
run "verify_default_tags" {
  command = plan

  assert {
    condition     = length(var.tags) == 0
    error_message = "Tags should be empty by default"
  }
}

# Test with BGP propagation disabled
run "verify_bgp_propagation_disabled" {
  command = plan

  variables {
    bgp_route_propagation_enabled = false
  }

  assert {
    condition     = azurerm_route_table.route_table.bgp_route_propagation_enabled == false
    error_message = "BGP route propagation should be disabled when explicitly set to false"
  }
}

# Test with tags
run "verify_tags" {
  command = plan

  variables {
    tags = {
      Environment = "Test"
      Project     = "UnitTest"
    }
  }

  assert {
    condition     = azurerm_route_table.route_table.tags["Environment"] == "Test"
    error_message = "Environment tag should be set correctly"
  }

  assert {
    condition     = azurerm_route_table.route_table.tags["Project"] == "UnitTest"
    error_message = "Project tag should be set correctly"
  }
}