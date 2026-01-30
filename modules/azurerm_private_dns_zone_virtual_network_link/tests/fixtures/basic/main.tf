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
  name     = "rg-pdns-link-basic-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-pdns-link-basic-${var.random_suffix}"
  address_space       = ["10.50.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "example" {
  name                = "example-${var.random_suffix}.internal"
  resource_group_name = azurerm_resource_group.example.name
}

module "private_dns_zone_virtual_network_link" {
  source = "../../../"

  name                  = "pdns-link-basic-${var.random_suffix}"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id

  tags = var.tags
}
