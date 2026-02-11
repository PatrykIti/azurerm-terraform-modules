# Naming validation tests for Private DNS Zone module

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
  resource_group_name = "test-rg"
}

run "invalid_name_with_underscore" {
  command = plan

  variables {
    name = "invalid_name"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_trailing_dot" {
  command = plan

  variables {
    name = "example.internal."
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_empty_label" {
  command = plan

  variables {
    name = "example..internal"
  }

  expect_failures = [
    var.name
  ]
}
