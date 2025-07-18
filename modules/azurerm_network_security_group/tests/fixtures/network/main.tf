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
  name     = "rg-nsg-net-${var.random_suffix}"
  location = var.location
}

module "network_security_group" {
  source = "../../.."

  name                = "nsg-net-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  security_rules = {
    allow_multiple_ports_and_sources = {
      priority                     = 200
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_ranges      = ["80", "8080", "443"]
      source_address_prefixes      = ["192.168.1.0/24", "10.10.0.0/16"]
      destination_address_prefix   = "VirtualNetwork"
      description                  = "Allow web traffic from multiple sources"
    }
  }

  tags = {
    Environment = "Test"
    Scenario    = "Network"
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