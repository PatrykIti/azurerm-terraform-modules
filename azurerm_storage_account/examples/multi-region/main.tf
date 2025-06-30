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
  features {}
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Primary region resource group
resource "azurerm_resource_group" "primary" {
  name     = "rg-storage-multi-primary"
  location = "West Europe"
}

# Secondary region resource group
resource "azurerm_resource_group" "secondary" {
  name     = "rg-storage-multi-secondary"
  location = "North Europe"
}

# Disaster recovery region resource group
resource "azurerm_resource_group" "dr" {
  name     = "rg-storage-multi-dr"
  location = "UK South"
}

# Log Analytics Workspace (shared across regions)
resource "azurerm_log_analytics_workspace" "shared" {
  name                = "law-storage-multi-${random_string.suffix.result}"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Primary Region Storage Account (GRS with failover capability)
module "primary_storage" {
  source = "../../"

  name                = "stprimary${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"  # Read-access geo-redundant storage
  access_tier              = "Hot"

  # Security settings
  min_tls_version                  = "TLS1_2"
  enable_https_traffic_only        = true
  allow_nested_items_to_be_public  = false
  enable_infrastructure_encryption = true

  # Failover configuration
  failover_enabled = true
  
  # Network rules (adjust for your environment)
  network_rules = {
    default_action = "Allow"  # Adjust based on security requirements
    bypass         = ["AzureServices", "Logging", "Metrics"]
  }

  # Monitoring
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id
    metrics                    = ["AllMetrics"]
    logs                       = ["StorageRead", "StorageWrite", "StorageDelete"]
  }

  # Blob properties for replication
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
    
    delete_retention_policy = {
      days = 30
    }
    
    container_delete_retention_policy = {
      days = 30
    }
  }

  # Identity for cross-region operations
  identity = {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
    Region      = "Primary"
    Role        = "Active"
    DR          = "Enabled"
  }
}

# Secondary Region Storage Account (Zone redundant)
module "secondary_storage" {
  source = "../../"

  name                = "stsecond${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.secondary.name
  location            = azurerm_resource_group.secondary.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"  # Zone-redundant in secondary region
  access_tier              = "Cool" # Cost optimization for secondary

  # Security settings
  min_tls_version                  = "TLS1_2"
  enable_https_traffic_only        = true
  allow_nested_items_to_be_public  = false
  enable_infrastructure_encryption = true

  # Network rules
  network_rules = {
    default_action = "Allow"
    bypass         = ["AzureServices", "Logging", "Metrics"]
  }

  # Monitoring
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id
    metrics                    = ["AllMetrics"]
    logs                       = ["StorageRead", "StorageWrite", "StorageDelete"]
  }

  # Blob properties
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = true
    
    delete_retention_policy = {
      days = 30
    }
  }

  # Lifecycle rules for cost optimization
  lifecycle_rules = [
    {
      name    = "archive-inactive-data"
      enabled = true
      
      filters = {
        blob_types = ["blockBlob"]
      }
      
      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than    = 30
          tier_to_archive_after_days_since_modification_greater_than = 90
          delete_after_days_since_modification_greater_than          = 365
        }
      }
    }
  ]

  # Identity
  identity = {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
    Region      = "Secondary"
    Role        = "Backup"
    DR          = "Target"
  }
}

# Disaster Recovery Storage Account (Archive focused)
module "dr_storage" {
  source = "../../"

  name                = "stdr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.dr.name
  location            = azurerm_resource_group.dr.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"  # Local redundancy sufficient for DR archive
  access_tier              = "Cool"

  # Security settings
  min_tls_version                  = "TLS1_2"
  enable_https_traffic_only        = true
  allow_nested_items_to_be_public  = false
  enable_infrastructure_encryption = true

  # Network rules
  network_rules = {
    default_action = "Allow"
    bypass         = ["AzureServices", "Logging", "Metrics"]
  }

  # Monitoring
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id
    metrics                    = ["AllMetrics"]
    logs                       = ["StorageRead", "StorageWrite", "StorageDelete"]
  }

  # Blob properties optimized for archive
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = false  # Not needed for archive
    
    delete_retention_policy = {
      days = 90  # Extended retention for DR
    }
  }

  # Aggressive lifecycle rules for cost optimization
  lifecycle_rules = [
    {
      name    = "immediate-archive"
      enabled = true
      
      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["archive/", "backup/"]
      }
      
      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than    = 1
          tier_to_archive_after_days_since_modification_greater_than = 7
        }
      }
    }
  ]

  # Identity
  identity = {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
    Region      = "DR"
    Role        = "Archive"
    DR          = "Backup"
  }
}

# Storage account for cross-region replication metadata
module "replication_metadata" {
  source = "../../"

  name                = "strepmeta${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"  # Geo-redundant for metadata
  access_tier              = "Hot"

  # Table storage for replication tracking
  table_storage_enabled = true

  # Queue storage for replication events
  queue_storage_enabled = true

  # Security settings
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true

  # Monitoring
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id
    metrics                    = ["AllMetrics"]
  }

  tags = {
    Environment = "Production"
    Purpose     = "ReplicationMetadata"
    Critical    = "Yes"
  }
}

# Outputs for cross-region replication setup
output "replication_setup" {
  value = {
    primary = {
      account_name          = module.primary_storage.name
      primary_endpoint      = module.primary_storage.primary_blob_endpoint
      secondary_endpoint    = module.primary_storage.secondary_blob_endpoint
      connection_string     = module.primary_storage.primary_connection_string
      identity_principal_id = module.primary_storage.identity.principal_id
    }
    secondary = {
      account_name          = module.secondary_storage.name
      endpoint              = module.secondary_storage.primary_blob_endpoint
      connection_string     = module.secondary_storage.primary_connection_string
      identity_principal_id = module.secondary_storage.identity.principal_id
    }
    dr = {
      account_name          = module.dr_storage.name
      endpoint              = module.dr_storage.primary_blob_endpoint
      connection_string     = module.dr_storage.primary_connection_string
      identity_principal_id = module.dr_storage.identity.principal_id
    }
    metadata = {
      account_name      = module.replication_metadata.name
      table_endpoint    = module.replication_metadata.primary_table_endpoint
      queue_endpoint    = module.replication_metadata.primary_queue_endpoint
      connection_string = module.replication_metadata.primary_connection_string
    }
  }
  sensitive = true
}