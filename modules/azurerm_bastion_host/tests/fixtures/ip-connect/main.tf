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
  name     = "rg-bastion-ipconnect-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-bastion-ipconnect-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.40.0.0/16"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.40.0.0/26"]
}

resource "azurerm_public_ip" "example" {
  name                = "pip-bastion-ipconnect-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "bastion_host" {
  source = "../../.."

  name                = "bastion-ipconnect-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku = "Standard"

  ip_configuration = [
    {
      name                 = "ipconfig-ipconnect"
      subnet_id            = azurerm_subnet.bastion.id
      public_ip_address_id = azurerm_public_ip.example.id
    }
  ]

  ip_connect_enabled = true

  tags = var.tags
}
