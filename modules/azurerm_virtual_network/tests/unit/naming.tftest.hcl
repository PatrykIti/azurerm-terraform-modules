mock_provider "azurerm" {
  mock_resource "azurerm_virtual_network" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
      name                = "vnet-test"
      location            = "westeurope"
      resource_group_name = "rg-test"
      address_space       = ["10.0.0.0/16"]
      dns_servers         = []
      guid                = "00000000-0000-0000-0000-000000000000"
      subnet              = []
    }
  }
}

variables {
  name                = "vnet-valid-name"
  resource_group_name = "rg-test"
  location            = "westeurope"
  address_space       = ["10.0.0.0/16"]
}

run "valid_name_is_applied" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.virtual_network.name == "vnet-valid-name"
    error_message = "VNet name should match the input value."
  }
}
