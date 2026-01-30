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
  name     = "rg-bastion-negative-test"
  location = "westeurope"
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-bastion-negative-test"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.95.0.0/16"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.95.0.0/26"]
}

resource "azurerm_public_ip" "test" {
  name                = "pip-bastion-negative-test"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "bastion_host" {
  source = "../../.."

  name                = "invalid name with spaces"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  ip_configuration = [
    {
      name                 = "ipconfig-invalid"
      subnet_id            = azurerm_subnet.bastion.id
      public_ip_address_id = azurerm_public_ip.test.id
    }
  ]

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
