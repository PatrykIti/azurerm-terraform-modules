terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-pe-negative"
  location = "westeurope"
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-pe-negative"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.50.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-pe-negative"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.50.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_storage_account" "test" {
  name                     = "stpenegative01"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
}

# This configuration should fail due to invalid DNS zone ID format
module "private_endpoint" {
  source = "../../.."

  name                = "pe-negative"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connections = [
    {
      name                           = "psc-negative"
      is_manual_connection           = false
      private_connection_resource_id = azurerm_storage_account.test.id
      subresource_names              = ["blob"]
    }
  ]

  private_dns_zone_groups = [
    {
      name                 = "dns-invalid"
      private_dns_zone_ids = ["not-a-valid-id"]
    }
  ]
}
