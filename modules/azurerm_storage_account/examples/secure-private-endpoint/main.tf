# Secure Storage Account with Private Endpoints Example
# This example demonstrates a highly secure storage account configuration
# suitable for production environments with sensitive data

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-secure-example"
  location = "West Europe"
  
  tags = {
    Environment        = "Production"
    SecurityLevel      = "High"
    DataClassification = "Confidential"
    Example            = "secure-private-endpoint"
  }
}

# Virtual Network for Private Endpoints
resource "azurerm_virtual_network" "example" {
  name                = "vnet-storage-secure"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  
  private_endpoint_network_policies_enabled = true
}

# Subnet for Application
resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
  
  service_endpoints = ["Microsoft.Storage"]
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# Link DNS zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "file-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Key Vault for Customer Managed Keys
resource "azurerm_key_vault" "example" {
  name                = "kv-storage-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  purge_protection_enabled    = true
  soft_delete_retention_days  = 90
  enabled_for_disk_encryption = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

# User Assigned Identity for Storage Account
resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-storage-secure"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Key Vault Access Policy for Identity
resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.storage.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey"
  ]
}

# Customer Managed Key
resource "azurerm_key_vault_key" "storage" {
  name         = "storage-encryption-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  depends_on = [azurerm_key_vault_access_policy.storage]
}

# Log Analytics Workspace for Diagnostics
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-storage-secure-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Data source for current client
data "azurerm_client_config" "current" {}

# Secure Storage Account Module
module "secure_storage" {
  source = "../../"

  name                = "stsecure${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Premium performance for enhanced security features
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2"

  # Maximum security settings
  min_tls_version                   = "TLS1_2"
  enable_https_traffic_only         = true
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = false
  infrastructure_encryption_enabled = true
  enable_advanced_threat_protection = true

  # Network security - deny all by default
  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []  # No public IPs allowed
    virtual_network_subnet_ids = [azurerm_subnet.app.id]
  }

  # Private endpoints for all services
  private_endpoints = {
    blob = {
      name                 = "pe-blob-${random_string.suffix.result}"
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
    }
    file = {
      name                 = "pe-file-${random_string.suffix.result}"
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.file.id]
    }
    queue = {
      name                 = "pe-queue-${random_string.suffix.result}"
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.queue.id]
    }
    table = {
      name                 = "pe-table-${random_string.suffix.result}"
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.table.id]
    }
  }

  # Identity for managed authentication
  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  # Customer managed key encryption
  customer_managed_key = {
    key_vault_key_id          = azurerm_key_vault_key.storage.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  # Enhanced data protection
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = true
    delete_retention_policy = {
      days = 30
    }
    container_delete_retention_policy = {
      days = 30
    }
  }

  # Comprehensive logging
  diagnostic_settings = {
    name                       = "diag-storage-secure"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    logs = [
      { category = "StorageRead" },
      { category = "StorageWrite" },
      { category = "StorageDelete" }
    ]
    metrics = [
      { category = "Transaction" },
      { category = "Capacity" }
    ]
  }

  tags = {
    Environment        = "Production"
    SecurityLevel      = "Maximum"
    DataClassification = "Confidential"
    CostCenter         = "Security"
    Owner              = "security-team@company.com"
    Purpose            = "Secure data storage with private endpoints"
  }

  depends_on = [
    azurerm_key_vault_access_policy.storage,
    azurerm_private_dns_zone_virtual_network_link.blob,
    azurerm_private_dns_zone_virtual_network_link.file
  ]
}