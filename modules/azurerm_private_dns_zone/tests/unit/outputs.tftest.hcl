# Output tests for Private DNS Zone module

mock_provider "azurerm" {
  mock_resource "azurerm_private_dns_zone" {
    defaults = {
      id                                                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/example.internal"
      name                                                  = "example.internal"
      resource_group_name                                   = "test-rg"
      number_of_record_sets                                 = 5
      max_number_of_virtual_network_links                   = 1000
      max_number_of_virtual_network_links_with_registration = 100
      tags = {
        Environment = "Test"
      }
      soa_record = [
        {
          email        = "hostmaster.example.internal"
          ttl          = 3600
          refresh_time = 3600
          retry_time   = 300
          expire_time  = 2419200
          minimum_ttl  = 300
        }
      ]
    }
  }
}

variables {
  name                = "example.internal"
  resource_group_name = "test-rg"
  tags = {
    Environment = "Test"
  }
}

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/example.internal"
    error_message = "Output 'id' should return the zone ID."
  }

  assert {
    condition     = output.name == "example.internal"
    error_message = "Output 'name' should return the zone name."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.number_of_record_sets == 5
    error_message = "Output 'number_of_record_sets' should return the record set count."
  }

  assert {
    condition     = output.max_number_of_virtual_network_links == 1000
    error_message = "Output 'max_number_of_virtual_network_links' should return the limit."
  }

  assert {
    condition     = output.max_number_of_virtual_network_links_with_registration == 100
    error_message = "Output 'max_number_of_virtual_network_links_with_registration' should return the limit."
  }

  assert {
    condition     = output.tags["Environment"] == "Test"
    error_message = "Output 'tags' should include the Environment tag."
  }
}
