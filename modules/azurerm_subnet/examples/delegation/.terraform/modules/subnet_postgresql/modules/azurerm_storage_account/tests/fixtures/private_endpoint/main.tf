terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-pep-${var.random_suffix}"
  location = var.location
}

# Virtual network for private endpoint
resource "azurerm_virtual_network" "test" {
  name                = "vnet-dpc-pep-${var.random_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "endpoint" {
  name                 = "subnet-endpoint"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

# Private DNS zone for blob storage
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-link"
  resource_group_name   = azurerm_resource_group.test.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.test.id
}

module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.1"

  name                     = "dpcpep${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enable shared access key for tests
  security_settings = {
    shared_access_key_enabled = true
  }

  # Network rules - deny all public access
  network_rules = {
    ip_rules                   = []
    virtual_network_subnet_ids = []
    bypass                     = [] # No bypass, completely private
  }


  tags = {
    Environment = "Test"
    TestType    = "PrivateEndpoint"
  }
}

# Private endpoint for blob storage
resource "azurerm_private_endpoint" "blob" {
  name                = "pe-${module.storage_account.name}-blob"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "psc-${module.storage_account.name}-blob"
    private_connection_resource_id = module.storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = {
    Environment = "Test"
    TestType    = "PrivateEndpoint"
  }
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "storage_account_id" {
  value = module.storage_account.id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.blob.id
}