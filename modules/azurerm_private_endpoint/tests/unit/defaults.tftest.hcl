# Test default settings for the Private Endpoint module

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
      network_interface = [
        {
          id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/test-pe-nic"
          name = "test-pe-nic"
        }
      ]
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

run "verify_defaults" {
  command = plan

  assert {
    condition     = length(var.ip_configurations) == 0
    error_message = "ip_configurations should be empty by default."
  }

  assert {
    condition     = length(var.private_dns_zone_groups) == 0
    error_message = "private_dns_zone_groups should be empty by default."
  }

  assert {
    condition     = var.custom_network_interface_name == null
    error_message = "custom_network_interface_name should be null by default."
  }

  assert {
    condition     = length(var.tags) == 0
    error_message = "tags should be empty by default."
  }
}
