# Validation tests for Private DNS Zone module

mock_provider "azurerm" {
  mock_resource "azurerm_private_dns_zone" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/example.internal"
      name                = "example.internal"
      resource_group_name = "test-rg"
    }
  }
}

variables {
  name                = "example.internal"
  resource_group_name = "test-rg"
}

run "invalid_soa_email" {
  command = plan

  variables {
    soa_record = {
      email = ""
    }
  }

  expect_failures = [
    var.soa_record
  ]
}

run "invalid_soa_ttl" {
  command = plan

  variables {
    soa_record = {
      email = "hostmaster.example.internal"
      ttl   = -1
    }
  }

  expect_failures = [
    var.soa_record
  ]
}
