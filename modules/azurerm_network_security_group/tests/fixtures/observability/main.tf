terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-nsg-obs-${var.random_suffix}"
  location = var.location
}

module "network_security_group" {
  source = "../../.."

  name                = "nsg-obs-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  security_rules = [
    {
      name                       = "allow_https"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Allow HTTPS inbound"
    }
  ]

  tags = {
    Environment = "Test"
    Scenario    = "Observability"
  }
}
