# tests/unit/defaults.tftest.hcl

mock_provider "azurerm" {
  mock_resource "azurerm_route_table" {
    defaults = {
      id                            = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.Network/routeTables/mock-rt"
      bgp_route_propagation_enabled = true
    }
  }
}

variables {
  name                = "test-rt"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "verify_bgp_propagation_default" {
  command = plan

  assert {
    condition     = azurerm_route_table.route_table.bgp_route_propagation_enabled == true
    error_message = "BGP route propagation should be enabled by default"
  }
}