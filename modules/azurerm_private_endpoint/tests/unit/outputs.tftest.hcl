# Test outputs for the Private Endpoint module

mock_provider "azurerm" {
  mock_resource "azurerm_private_endpoint" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateEndpoints/test-pe"
      name                          = "test-pe"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-snet"
      custom_network_interface_name = "test-pe-nic"
      tags = {
        Environment = "Test"
      }
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
      ip_configuration = []
      private_dns_zone_group = [
        {
          id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateEndpoints/test-pe/privateDnsZoneGroups/test-group"
          name                 = "test-group"
          private_dns_zone_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
        }
      ]
      custom_dns_configs = [
        {
          fqdn         = "test.blob.core.windows.net"
          ip_addresses = ["10.0.1.4"]
        }
      ]
      private_dns_zone_configs = []
    }
  }
}

variables {
  name                = "test-pe"
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

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateEndpoints/test-pe"
    error_message = "Output 'id' should return the private endpoint ID."
  }

  assert {
    condition     = output.name == "test-pe"
    error_message = "Output 'name' should return the private endpoint name."
  }

  assert {
    condition     = output.location == "northeurope"
    error_message = "Output 'location' should return the private endpoint location."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.subnet_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-snet"
    error_message = "Output 'subnet_id' should return the subnet ID."
  }
}

run "verify_private_ip_output" {
  command = plan

  assert {
    condition     = output.private_ip_address == "10.0.1.4"
    error_message = "Output 'private_ip_address' should return the service connection private IP."
  }
}

run "verify_dns_group_output" {
  command = plan

  assert {
    condition     = length(output.private_dns_zone_group) == 1
    error_message = "Output 'private_dns_zone_group' should return the configured DNS zone group."
  }

  assert {
    condition     = output.private_dns_zone_group[0].name == "test-group"
    error_message = "Output 'private_dns_zone_group' should include the DNS zone group name."
  }
}
