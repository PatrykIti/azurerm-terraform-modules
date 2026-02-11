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
  name     = "rg-pe-dns-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-pe-dns-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.41.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-pe-dns-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.41.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_storage_account" "example" {
  name                     = "stpedns${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"

  tags = var.tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "vnet-link-blob-${var.random_suffix}"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
  tags                  = var.tags
}

module "private_endpoint" {
  source = "../../.."

  name                = "pe-dns-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connections = [
    {
      name                           = "psc-dns-${var.random_suffix}"
      is_manual_connection           = false
      private_connection_resource_id = azurerm_storage_account.example.id
      subresource_names              = ["blob"]
    }
  ]

  private_dns_zone_groups = [
    {
      name                 = "dns-${var.random_suffix}"
      private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
    }
  ]

  tags = var.tags
}
