# Basic Subnet Example
# This example demonstrates the minimal configuration required to create a subnet

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-basic-${var.name_suffix}"
  location = var.location

  tags = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-basic-${var.name_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}

# Subnet Module - Basic Configuration
module "subnet" {
  source = "../../"

  name                 = "subnet-basic-${var.name_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  tags = var.tags
}