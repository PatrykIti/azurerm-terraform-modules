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
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "redis" {
  name                 = "snet-redis"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.20.1.0/24"]
}

module "redis_cache" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_redis_cache?ref=REDISv1.0.0"

  name                = var.redis_cache_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = "Premium"
  family   = "P"
  capacity = 1

  public_network_access_enabled = false
  subnet_id                     = azurerm_subnet.redis.id
  private_static_ip_address     = "10.20.1.4"

  minimum_tls_version  = "1.2"
  non_ssl_port_enabled = false

  access_keys_authentication_enabled = false
  redis_configuration = {
    active_directory_authentication_enabled = true
  }

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
