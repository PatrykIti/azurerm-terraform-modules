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

resource "azurerm_resource_group" "example" {
  name     = "rg-pe-basic-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-pe-basic-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-pe-basic-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.10.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_storage_account" "example" {
  name                     = "stpebasic${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"

  tags = var.tags
}

module "private_endpoint" {
  source = "../../.."

  name                = "pe-basic-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connections = [
    {
      name                           = "psc-basic-${var.random_suffix}"
      is_manual_connection           = false
      private_connection_resource_id = azurerm_storage_account.example.id
      subresource_names              = ["blob"]
    }
  ]

  tags = var.tags
}
