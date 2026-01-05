# Private Endpoint Subnet Example
# This example configures a subnet for private endpoints and creates a private endpoint to a storage account

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

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create a Virtual Network for the subnet
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet configured for private endpoints
module "subnet" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.1.0"

  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Required for private endpoints
  private_endpoint_network_policies_enabled = false
}

# Storage account used for the private endpoint example
resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Private endpoint for the storage account
resource "azurerm_private_endpoint" "example" {
  name                = var.private_endpoint_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = module.subnet.id

  private_service_connection {
    name                           = "psc-subnet-private-endpoint-example"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}
