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
