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

# Test fixture for basic NSG testing
resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = var.location
}

module "test_nsg" {
  source = "../../"

  name                = var.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  security_rules = var.security_rules
  tags           = var.tags
}

# Variables for testing
variable "resource_group_name" {
  description = "Resource group name for testing"
  type        = string
}

variable "location" {
  description = "Azure region for testing"
  type        = string
}

variable "name" {
  description = "NSG name for testing"
  type        = string
}

variable "security_rules" {
  description = "Security rules for testing"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags for testing"
  type        = map(string)
  default     = {}
}

# Outputs for verification
output "nsg_id" {
  value = module.test_nsg.id
}

output "nsg_name" {
  value = module.test_nsg.name
}

output "security_rule_ids" {
  value = module.test_nsg.security_rule_ids
}