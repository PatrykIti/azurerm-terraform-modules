# Private Endpoint Integration Example
# This example demonstrates Virtual Network configuration for private endpoint scenarios

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.35.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create a resource group for this example
resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-pep-${var.random_suffix}"
  location = var.location
}

# Create Private DNS Zone for storage account
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "PrivateEndpoint"
  }
}

# Virtual Network optimized for private endpoint scenarios
module "virtual_network" {
  source = "../../../"

  name                = "vnet-dpc-pep-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]

  # DNS configuration for private endpoint resolution
  dns_servers = [] # Use Azure-provided DNS for private endpoint resolution

  # Network flow configuration
  flow_timeout_in_minutes = 10

  # Private DNS Zone Links for private endpoint resolution
  private_dns_zone_links = [
    {
      name                  = "link-to-blob-storage"
      resource_group_name   = azurerm_resource_group.test.name
      private_dns_zone_name = azurerm_private_dns_zone.blob.name
      registration_enabled  = false # Auto-registration not needed for private endpoints
      tags = {
        Purpose = "Private Endpoint DNS Resolution"
      }
    }
  ]

  # Lifecycle Management

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "PrivateEndpoint"
  }
}

# Create subnet for private endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "subnet-private-endpoints"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]

  # Disable network policies for private endpoints
  private_endpoint_network_policies = "Disabled"

  depends_on = [module.virtual_network]
}

# Create subnet for application workloads
resource "azurerm_subnet" "workloads" {
  name                 = "subnet-workloads"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [module.virtual_network]
}

# Use the Storage Account module to demonstrate private endpoint connectivity
module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0"

  name                     = "dpcpep${random_string.suffix.result}${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enable shared access key for tests
  security_settings = {
    shared_access_key_enabled = true
  }

  # Network rules - deny all public access
  network_rules = {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
    bypass                     = [] # No bypass, completely private
  }

  # Private endpoint configuration
  private_endpoints = [
    {
      name                 = "blob-endpoint"
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
      subresource_names    = ["blob"]
    }
  ]

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "PrivateEndpoint"
  }
}