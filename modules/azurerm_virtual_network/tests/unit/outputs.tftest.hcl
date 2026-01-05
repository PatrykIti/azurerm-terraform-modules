mock_provider "azurerm" {
  mock_resource "azurerm_virtual_network" {
    defaults = {
      id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
      name                    = "vnet-test"
      location                = "westeurope"
      resource_group_name     = "rg-test"
      address_space           = ["10.0.0.0/16"]
      dns_servers             = ["10.0.1.4"]
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

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id != null && output.id != ""
    error_message = "ID output should not be empty."
  }

  assert {
    condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Network/virtualNetworks/.*", output.id))
    error_message = "ID output should be a valid Azure resource ID."
  }

  assert {
    condition     = output.name == "vnet-test"
    error_message = "Name output should match the VNet name."
  }

  assert {
    condition     = length(output.address_space) == 1
    error_message = "address_space output should include one CIDR by default."
  }

  assert {
    condition     = output.network_configuration.ddos_protection_enabled == false
    error_message = "ddos_protection_enabled should be false by default."
  }

  assert {
    condition     = output.network_configuration.encryption_enabled == false
    error_message = "encryption_enabled should be false by default."
  }
}
