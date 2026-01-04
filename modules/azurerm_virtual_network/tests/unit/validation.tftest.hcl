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

run "invalid_name" {
  command = plan

  variables {
    name = "-invalid"
  }

  expect_failures = [
    var.name,
  ]
}

run "invalid_address_space" {
  command = plan

  variables {
    address_space = ["not-a-cidr"]
  }

  expect_failures = [
    var.address_space,
  ]
}

run "invalid_dns_server" {
  command = plan

  variables {
    dns_servers = ["not-an-ip"]
  }

  expect_failures = [
    var.dns_servers,
  ]
}

run "invalid_encryption_enforcement" {
  command = plan

  variables {
    encryption = {
      enforcement = "Invalid"
    }
  }

  expect_failures = [
    var.encryption,
  ]
}

run "empty_resource_group" {
  command = plan

  variables {
    resource_group_name = ""
  }

  expect_failures = [
    var.resource_group_name,
  ]
}

run "empty_location" {
  command = plan

  variables {
    location = ""
  }

  expect_failures = [
    var.location,
  ]
}
