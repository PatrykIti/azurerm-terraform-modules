# Negative Route Table Test Cases
# This fixture contains multiple test cases that should fail validation

terraform {
  required_version = ">= 1.11.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-rt-neg-${var.random_suffix}"
  location = var.location
}

# Test Case 1: Invalid route table name (too long)
# module "invalid_name_too_long" {
#   source = "../../.."
#
#   name                = "this-is-a-very-long-route-table-name-that-exceeds-the-maximum-allowed-length-of-80-characters"
#   resource_group_name = azurerm_resource_group.test.name
#   location            = azurerm_resource_group.test.location
# }

# Test Case 2: Invalid route table name (invalid characters)
# module "invalid_name_chars" {
#   source = "../../.."
#
#   name                = "route-table-with-invalid-chars!@#"
#   resource_group_name = azurerm_resource_group.test.name
#   location            = azurerm_resource_group.test.location
# }

# Test Case 3: Invalid route configuration - missing next_hop_in_ip_address for VirtualAppliance
# module "invalid_route_missing_ip" {
#   source = "../../.."
#
#   name                = "rt-neg-missing-ip-${var.random_suffix}"
#   resource_group_name = azurerm_resource_group.test.name
#   location            = azurerm_resource_group.test.location
#
#   routes = [
#     {
#       name                   = "invalid-route"
#       address_prefix         = "10.0.0.0/16"
#       next_hop_type          = "VirtualAppliance"
#       next_hop_in_ip_address = null  # This should fail - IP required for VirtualAppliance
#     }
#   ]
# }

# Test Case 4: Invalid route configuration - IP address provided for non-VirtualAppliance
# module "invalid_route_unexpected_ip" {
#   source = "../../.."
#
#   name                = "rt-neg-unexpected-ip-${var.random_suffix}"
#   resource_group_name = azurerm_resource_group.test.name
#   location            = azurerm_resource_group.test.location
#
#   routes = [
#     {
#       name                   = "invalid-route"
#       address_prefix         = "10.0.0.0/16"
#       next_hop_type          = "Internet"
#       next_hop_in_ip_address = "10.0.0.4"  # This should fail - IP not allowed for Internet
#     }
#   ]
# }

# Test Case 5: Invalid route configuration - invalid next_hop_type
# module "invalid_route_hop_type" {
#   source = "../../.."
#
#   name                = "rt-neg-hop-type-${var.random_suffix}"
#   resource_group_name = azurerm_resource_group.test.name
#   location            = azurerm_resource_group.test.location
#
#   routes = [
#     {
#       name                   = "invalid-route"
#       address_prefix         = "10.0.0.0/16"
#       next_hop_type          = "InvalidType"  # This should fail - invalid hop type
#       next_hop_in_ip_address = null
#     }
#   ]
# }

# Test Case 6: Invalid route configuration - invalid IP address format
# module "invalid_route_ip_format" {
#   source = "../../.."
#
#   name                = "rt-neg-ip-format-${var.random_suffix}"
#   resource_group_name = azurerm_resource_group.test.name
#   location            = azurerm_resource_group.test.location
#
#   routes = [
#     {
#       name                   = "invalid-route"
#       address_prefix         = "10.0.0.0/16"
#       next_hop_type          = "VirtualAppliance"
#       next_hop_in_ip_address = "256.256.256.256"  # This should fail - invalid IP
#     }
#   ]
# }

# Test Case 7: Invalid route configuration - invalid CIDR notation
# module "invalid_route_cidr" {
#   source = "../../.."
#
#   name                = "rt-neg-cidr-${var.random_suffix}"
#   resource_group_name = azurerm_resource_group.test.name
#   location            = azurerm_resource_group.test.location
#
#   routes = [
#     {
#       name                   = "invalid-route"
#       address_prefix         = "10.0.0.0/33"  # This should fail - invalid CIDR
#       next_hop_type          = "Internet"
#       next_hop_in_ip_address = null
#     }
#   ]
# }

# Test Case 8: Invalid route configuration - duplicate route names
# module "invalid_duplicate_routes" {
#   source = "../../.."
#
#   name                = "rt-neg-dup-${var.random_suffix}"
#   resource_group_name = azurerm_resource_group.test.name
#   location            = azurerm_resource_group.test.location
#
#   routes = [
#     {
#       name                   = "duplicate-name"
#       address_prefix         = "10.0.0.0/16"
#       next_hop_type          = "Internet"
#       next_hop_in_ip_address = null
#     },
#     {
#       name                   = "duplicate-name"  # This should fail - duplicate name
#       address_prefix         = "10.1.0.0/16"
#       next_hop_type          = "Internet"
#       next_hop_in_ip_address = null
#     }
#   ]
# }

# Module configuration for validation testing
module "route_table_validation" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.2"

  # Use provided name or default name
  name                = var.name != "" ? var.name : "rt-neg-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  # Routes come from variables for validation testing
  routes = var.routes

  tags = {
    Environment = "Test"
    Example     = "Negative"
    Purpose     = "Validation testing"
  }
}
