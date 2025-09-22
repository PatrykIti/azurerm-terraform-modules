# Private Endpoint Integration Example
# This example demonstrates Virtual Network configuration for private endpoint scenarios

terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-vnet-private-endpoint-example"
  location = var.location
}

# Create a storage account to demonstrate private endpoint connectivity
resource "azurerm_storage_account" "example" {
  name                     = "stvnetprivateendpoint"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Disable public access to force private endpoint usage
  public_network_access_enabled = false

  tags = {
    Environment = "Development"
    Purpose     = "Private Endpoint Demo"
  }
}

# Create Private DNS Zone for storage account
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Purpose     = "Private DNS for Storage"
  }
}

# Virtual Network optimized for private endpoint scenarios
module "virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.2"

  name                = "vnet-private-endpoint-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  # DNS configuration for private endpoint resolution
  dns_servers = [] # Use Azure-provided DNS for private endpoint resolution

  # Network flow configuration
  flow_timeout_in_minutes = 10

  # Lifecycle Management

  tags = {
    Environment = "Development"
    Example     = "Private-Endpoint"
    Purpose     = "Virtual Network for Private Endpoint Integration"
    NetworkType = "Private"
  }
}

# Create subnet for private endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "subnet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]

  # Disable network policies for private endpoints
  private_endpoint_network_policies = "Disabled"

  depends_on = [module.virtual_network]
}

# Create subnet for application workloads
resource "azurerm_subnet" "workloads" {
  name                 = "subnet-workloads"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [module.virtual_network]
}

# Create private endpoint for storage account
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage-blob"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-storage-blob"
    private_connection_resource_id = azurerm_storage_account.example.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "dns-zone-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = {
    Environment = "Development"
    Purpose     = "Storage Private Endpoint"
  }

  depends_on = [
    module.virtual_network,
    azurerm_subnet.private_endpoints
  ]
}
