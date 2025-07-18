provider "azurerm" {
  features {}
}

variable "random_suffix" {
  type        = string
  description = "A random suffix passed from the test to ensure unique resource names."
}

variable "location" {
  type        = string
  description = "The Azure region for the resources."
}

resource "azurerm_resource_group" "test" {
  name     = "rg-nsg-sec-${var.random_suffix}"
  location = var.location
}

module "network_security_group" {
  source = "../../.."

  name                = "nsg-sec-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  security_rules = {
    deny_all_inbound = {
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny all inbound traffic from the Internet"
    }
    allow_corp_outbound = {
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "10.0.0.0/8" # Corp network
      description                = "Allow outbound HTTPS to corporate network"
    }
  }

  tags = {
    Environment = "Test"
    Scenario    = "Security"
  }
}

output "id" {
  description = "The ID of the created Network Security Group."
  value       = module.network_security_group.id
}

output "name" {
  description = "The name of the created Network Security Group."
  value       = module.network_security_group.name
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.test.name
}