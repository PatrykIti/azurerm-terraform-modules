mock_provider "azurerm" {
  mock_resource "azurerm_virtual_network" {
    defaults = {
      id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
      name                    = "vnet-test"
      location                = "westeurope"
      resource_group_name     = "rg-test"
      address_space           = ["10.0.0.0/16"]
      dns_servers             = []
      guid                    = "00000000-0000-0000-0000-000000000000"
      subnet                  = []
      flow_timeout_in_minutes = 4
      bgp_community           = null
      edge_zone               = null
    }
  }
}

variables {
  name                = "vnet-test"
  resource_group_name = "rg-test"
  location            = "westeurope"
  address_space       = ["10.0.0.0/16"]
}

run "verify_default_values" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.virtual_network.flow_timeout_in_minutes == 4
    error_message = "flow_timeout_in_minutes should default to 4."
  }

  assert {
    condition     = length(azurerm_virtual_network.virtual_network.dns_servers) == 0
    error_message = "dns_servers should default to an empty list."
  }

  assert {
    condition     = length(azurerm_virtual_network.virtual_network.ddos_protection_plan) == 0
    error_message = "ddos_protection_plan block should be omitted by default."
  }

  assert {
    condition     = length(azurerm_virtual_network.virtual_network.encryption) == 0
    error_message = "encryption block should be omitted by default."
  }
}
