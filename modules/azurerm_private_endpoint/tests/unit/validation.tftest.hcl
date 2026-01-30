# Test variable validation for the Private Endpoint module

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
  name                = "pe-unit"
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

run "missing_resource_id_and_alias" {
  command = plan

  variables {
    private_service_connections = [
      {
        name                 = "psc-missing"
        is_manual_connection = false
        subresource_names    = ["blob"]
      }
    ]
  }

  expect_failures = [
    var.private_service_connections
  ]
}

run "both_resource_id_and_alias" {
  command = plan

  variables {
    private_service_connections = [
      {
        name                              = "psc-invalid"
        is_manual_connection              = false
        private_connection_resource_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
        private_connection_resource_alias = "privatelink.blob.core.windows.net"
        subresource_names                 = ["blob"]
      }
    ]
  }

  expect_failures = [
    var.private_service_connections
  ]
}

run "manual_connection_missing_request_message" {
  command = plan

  variables {
    private_service_connections = [
      {
        name                           = "psc-manual"
        is_manual_connection           = true
        private_connection_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
        subresource_names              = ["blob"]
      }
    ]
  }

  expect_failures = [
    var.private_service_connections
  ]
}

run "duplicate_ip_configuration_names" {
  command = plan

  variables {
    ip_configurations = [
      {
        name               = "dup"
        private_ip_address = "10.0.1.5"
      },
      {
        name               = "dup"
        private_ip_address = "10.0.1.6"
      }
    ]
  }

  expect_failures = [
    var.ip_configurations
  ]
}

run "multiple_private_dns_zone_groups" {
  command = plan

  variables {
    private_dns_zone_groups = [
      {
        name                 = "dns-one"
        private_dns_zone_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
      },
      {
        name                 = "dns-two"
        private_dns_zone_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"]
      }
    ]
  }

  expect_failures = [
    var.private_dns_zone_groups
  ]
}

run "invalid_private_dns_zone_id" {
  command = plan

  variables {
    private_dns_zone_groups = [
      {
        name                 = "dns-invalid"
        private_dns_zone_ids = ["not-a-valid-id"]
      }
    ]
  }

  expect_failures = [
    var.private_dns_zone_groups
  ]
}
