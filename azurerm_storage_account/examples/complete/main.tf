terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-complete-example"
  location = "West Europe"
}

# Virtual Network for Private Endpoints
resource "azurerm_virtual_network" "example" {
  name                = "vnet-storage-example"
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

  private_endpoint_network_policies_enabled = false
}

# Subnet for allowed services
resource "azurerm_subnet" "services" {
  name                 = "snet-services"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

# Log Analytics Workspace for diagnostics
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-storage-example-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# User Assigned Identity for CMK
resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-storage-cmk-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Key Vault for Customer Managed Keys
resource "azurerm_key_vault" "example" {
  name                       = "kv-st-${random_string.suffix.result}"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create", "Get", "List", "Delete", "Purge", "Recover", "Update",
      "GetRotationPolicy", "SetRotationPolicy"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.storage.principal_id

    key_permissions = [
      "Get", "UnwrapKey", "WrapKey"
    ]
  }
}

# Key for Storage Encryption
resource "azurerm_key_vault_key" "storage" {
  name         = "storage-encryption-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"
  ]

  depends_on = [azurerm_key_vault.example]
}

# Private DNS Zones for Private Endpoints
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
  name                  = "blob-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "file-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Current client configuration
data "azurerm_client_config" "current" {}

# Complete Storage Account with all features
module "storage_account" {
  source = "../../"

  name                = "stcomplete${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  access_tier              = "Hot"

  # Security settings
  min_tls_version                  = "TLS1_2"
  enable_https_traffic_only        = true
  shared_access_key_enabled        = false
  allow_nested_items_to_be_public  = false
  enable_infrastructure_encryption = true
  cross_tenant_replication_enabled = false

  # Network security
  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    ip_rules                   = ["203.0.113.0/24"]  # Example IP range
    virtual_network_subnet_ids = [azurerm_subnet.services.id]
  }

  # Private endpoints
  private_endpoints = {
    blob = {
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
    }
    file = {
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.file.id]
    }
    queue = {
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.queue.id]
    }
    table = {
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.table.id]
    }
  }

  # Monitoring
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    metrics                    = ["AllMetrics"]
    logs = [
      "StorageRead",
      "StorageWrite",
      "StorageDelete",
      "Transaction"
    ]
    retention_days = 30
  }

  # Identity
  identity = {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  # Customer Managed Key encryption
  customer_managed_key = {
    key_vault_key_id          = azurerm_key_vault_key.storage.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  # Blob properties
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    change_feed_retention_in_days = 30
    last_access_time_enabled = true
    
    delete_retention_policy = {
      days = 30
    }
    
    container_delete_retention_policy = {
      days = 30
    }
    
    cors_rule = [{
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT"]
      allowed_origins    = ["https://example.com"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }]
  }

  # Queue properties
  queue_properties = {
    cors_rule = [{
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST"]
      allowed_origins    = ["https://example.com"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }]
    
    logging = {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 30
    }
    
    hour_metrics = {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 30
    }
    
    minute_metrics = {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 30
    }
  }

  # Share properties
  share_properties = {
    cors_rule = [{
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST"]
      allowed_origins    = ["https://example.com"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }]
    
    retention_policy = {
      days = 30
    }
    
    smb = {
      versions                        = ["SMB3.0", "SMB3.1.1"]
      authentication_types            = ["Kerberos", "NTLMv2"]
      kerberos_ticket_encryption_type = ["AES-256", "RC4-HMAC"]
      channel_encryption_type         = ["AES-128-CCM", "AES-128-GCM", "AES-256-GCM"]
    }
  }

  # Lifecycle management rules
  lifecycle_rules = [
    {
      name    = "archive-old-blobs"
      enabled = true
      
      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["logs/"]
      }
      
      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than    = 30
          tier_to_archive_after_days_since_modification_greater_than = 90
          delete_after_days_since_modification_greater_than          = 365
        }
        
        snapshot = {
          delete_after_days_since_creation_greater_than = 90
        }
        
        version = {
          delete_after_days_since_creation = 90
        }
      }
    },
    {
      name    = "delete-temp-data"
      enabled = true
      
      filters = {
        blob_types   = ["blockBlob", "appendBlob"]
        prefix_match = ["temp/"]
      }
      
      actions = {
        base_blob = {
          delete_after_days_since_modification_greater_than = 7
        }
      }
    }
  ]

  # Static website (optional)
  static_website = {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  # Advanced threat protection
  advanced_threat_protection_enabled = true

  tags = {
    Environment   = "Production"
    Example       = "Complete"
    Compliance    = "PCI-DSS"
    DataClass     = "Confidential"
    CostCenter    = "IT-Security"
    Owner         = "Platform Team"
    ManagedBy     = "Terraform"
  }

  depends_on = [
    azurerm_key_vault_key.storage,
    azurerm_private_dns_zone_virtual_network_link.blob,
    azurerm_private_dns_zone_virtual_network_link.file
  ]
}