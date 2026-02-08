# Test naming conventions for the Private Endpoint module

mock_provider "azurerm" {
  mock_resource "azurerm_private_endpoint" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateEndpoints/test-pe"
      name                          = "test-pe"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-snet"
      custom_network_interface_name = null
      tags                          = {}
      private_service_connection = [
        {
          name                              = "psc-unit"
          is_manual_connection              = false
          private_connection_resource_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
          private_connection_resource_alias = null
          subresource_names                 = ["blob"]
          request_message                   = null
          private_ip_address                = "10.0.1.4"
        }
      ]
      ip_configuration         = []
      private_dns_zone_group   = []
      custom_dns_configs       = []
      private_dns_zone_configs = []
    }
  }
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-snet"
  private_service_connections = [
    {
      name                           = "psc-unit"
      is_manual_connection           = false
      private_connection_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
      subresource_names              = ["blob"]
    }
  ]
}

run "valid_name" {
  command = plan

  variables {
    name = "pe-prod-westeu-001"
  }

  assert {
    condition     = azurerm_private_endpoint.private_endpoint.name == "pe-prod-westeu-001"
    error_message = "Private Endpoint name should match the input."
  }
}

run "valid_name_with_underscores" {
  command = plan

  variables {
    name = "pe_prod_westeu_001"
  }

  assert {
    condition     = azurerm_private_endpoint.private_endpoint.name == "pe_prod_westeu_001"
    error_message = "Private Endpoint name with underscores should be valid."
  }
}

run "invalid_name_with_space" {
  command = plan

  variables {
    name = "pe invalid"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_starts_with_symbol" {
  command = plan

  variables {
    name = "-pe-invalid"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_too_long" {
  command = plan

  variables {
    name = "pe-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  expect_failures = [
    var.name
  ]
}
