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
  name     = "rg-nsg-smp-${var.random_suffix}"
  location = var.location
}

module "network_security_group" {
  source = "../../.."

  name                = "nsg-smp-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    Environment = "Test"
    Scenario    = "Simple"
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