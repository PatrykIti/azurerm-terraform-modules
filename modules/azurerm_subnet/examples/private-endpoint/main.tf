# Private Endpoint Subnet Example
# This example demonstrates Subnet configuration optimized for private endpoint scenarios

terraform {
  required_version = ">= 1.12.2"
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

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-private-endpoint-example"
  location = var.location
}

# Create a Virtual Network for private endpoint connectivity
resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-private-endpoint-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  # Use Azure-provided DNS for private endpoint resolution
  dns_servers = []

  tags = {
    Environment = "Development"
    Example     = "Private-Endpoint"
    Purpose     = "Private Endpoint Connectivity"
  }
}

# Create a storage account to demonstrate private endpoint connectivity
resource "azurerm_storage_account" "example" {
  name                     = "stsubnetprivateendpt"
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

# Create Key Vault for additional private endpoint demonstration
resource "azurerm_key_vault" "example" {
  name                       = "kv-subnet-pe-example"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Disable public access
  public_network_access_enabled = false

  tags = {
    Environment = "Development"
    Purpose     = "Private Endpoint Demo"
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Create Private DNS Zone for storage account blob
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Purpose     = "Private DNS for Storage Blob"
  }
}

# Create Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Purpose     = "Private DNS for Key Vault"
  }
}

# Subnet optimized for private endpoints
module "subnet_private_endpoints" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.0"

  name                 = "subnet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # No service endpoints needed when using private endpoints
  service_endpoints               = []
  service_endpoint_policy_ids     = []

  # Disable network policies for private endpoints (required for private endpoints)
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_virtual_network.example]
}

# Subnet for application workloads that will access private endpoints
module "subnet_workloads" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.0"

  name                 = "subnet-workloads"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  # No special configuration needed for workload subnet
  service_endpoints                               = []
  service_endpoint_policy_ids                     = []
  private_endpoint_network_policies_enabled       = true
  private_link_service_network_policies_enabled   = true

  depends_on = [azurerm_virtual_network.example]
}

# Link Private DNS zones to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob-to-vnet"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false

  tags = {
    Environment = "Development"
    Purpose     = "Private DNS Resolution for Blob"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "link-keyvault-to-vnet"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false

  tags = {
    Environment = "Development"
    Purpose     = "Private DNS Resolution for Key Vault"
  }
}

# Create private endpoint for storage account blob
resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pe-storage-blob"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = module.subnet_private_endpoints.id

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
    Purpose     = "Storage Blob Private Endpoint"
  }

  depends_on = [module.subnet_private_endpoints]
}

# Create private endpoint for Key Vault
resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-keyvault"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = module.subnet_private_endpoints.id

  private_service_connection {
    name                           = "psc-keyvault"
    private_connection_resource_id = azurerm_key_vault.example.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "dns-zone-group-keyvault"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]
  }

  tags = {
    Environment = "Development"
    Purpose     = "Key Vault Private Endpoint"
  }

  depends_on = [module.subnet_private_endpoints]
}