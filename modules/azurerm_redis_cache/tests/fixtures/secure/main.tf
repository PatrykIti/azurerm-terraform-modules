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
  name     = "rg-redis-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-redis-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.40.0.0/16"]
}

resource "azurerm_subnet" "redis" {
  name                 = "snet-redis"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.40.1.0/24"]
}

module "redis_cache" {
  source = "../../.."

  name                = "redissecure${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = "Premium"
  family   = "P"
  capacity = 1

  public_network_access_enabled = false
  subnet_id                     = azurerm_subnet.redis.id
  private_static_ip_address     = "10.40.1.4"

  minimum_tls_version  = "1.2"
  non_ssl_port_enabled = false

  access_keys_authentication_enabled = false
  redis_configuration = {
    active_directory_authentication_enabled = true
  }

  tags = var.tags
}
