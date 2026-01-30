terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}


# Primary region resource group
resource "azurerm_resource_group" "primary" {
  name     = "rg-${var.resource_prefix}-primary"
  location = var.primary_location
}

# Secondary region resource group
resource "azurerm_resource_group" "secondary" {
  name     = "rg-${var.resource_prefix}-secondary"
  location = var.secondary_location
}

# Disaster recovery region resource group
resource "azurerm_resource_group" "dr" {
  name     = "rg-${var.resource_prefix}-dr"
  location = var.dr_location
}

# Log Analytics Workspace (shared across regions)
resource "azurerm_log_analytics_workspace" "shared" {
  name                = "law-storage-multiregion-ex"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Primary Region Storage Account (GRS with failover capability)
module "primary_storage" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                = "stprimarymultiregionex"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GZRS" # Geo-zone-redundant storage for maximum availability
  access_tier              = "Hot"

  # Enable cross-tenant replication for disaster recovery scenarios
  cross_tenant_replication_enabled = true

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true # Required for Terraform to manage the resource
    allow_nested_items_to_be_public = false
  }

  # Encryption settings
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
  }

  # Network rules - automatically defaults to Deny for security
  # Only specify if you need to allow specific IPs or subnets
  network_rules = var.enable_private_endpoints ? {
    bypass   = ["AzureServices", "Logging", "Metrics"]
    ip_rules = var.allowed_ip_ranges
  } : null


  # Blob properties for replication
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true

    delete_retention_policy = {
      enabled = true
      days    = 30
    }

    container_delete_retention_policy = {
      enabled = true
      days    = 30
    }
  }

  # Identity for cross-region operations
  identity = {
    type = "SystemAssigned"
  }

  # Lifecycle rules for geo-redundancy optimization
  lifecycle_rules = [
    {
      name    = "optimize-geo-redundancy"
      enabled = true

      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["logs/", "temp/"]
      }

      actions = {
        base_blob = {
          # Move to cool tier after 30 days for cost optimization
          tier_to_cool_after_days_since_modification_greater_than = 30
          # Delete temporary data after 90 days
          delete_after_days_since_modification_greater_than = 90
        }
      }
    },
    {
      name    = "archive-old-data"
      enabled = true

      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["archive/", "backup/"]
      }

      actions = {
        base_blob = {
          # Move to cool tier after 7 days
          tier_to_cool_after_days_since_modification_greater_than = 7
          # Move to archive tier after 30 days
          tier_to_archive_after_days_since_modification_greater_than = 30
          # Keep archived data for 365 days
          delete_after_days_since_modification_greater_than = 365
        }
      }
    }
  ]

  # Containers for primary storage
  containers = [
    {
      name                  = "production-data"
      container_access_type = "private"
    },
    {
      name                  = "logs"
      container_access_type = "private"
    },
    {
      name                  = "temp"
      container_access_type = "private"
    },
    {
      name                  = "archive"
      container_access_type = "private"
    }
  ]

  tags = merge(var.tags, {
    Environment = "Production"
    Region      = "Primary"
    Role        = "Active"
    DR          = "Enabled"
  })
}

# Secondary Region Storage Account (Zone redundant)
module "secondary_storage" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                = "stsecondmultiregionex"
  resource_group_name = azurerm_resource_group.secondary.name
  location            = azurerm_resource_group.secondary.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"  # Zone-redundant in secondary region
  access_tier              = "Cool" # Cost optimization for secondary

  # Enable cross-tenant replication for multi-tenant DR scenarios
  cross_tenant_replication_enabled = true

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true # Required for Terraform to manage the resource
    allow_nested_items_to_be_public = false
  }

  # Encryption settings
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
  }

  # Network rules - automatically defaults to Deny for security
  # Only specify if you need to allow specific IPs or subnets
  network_rules = var.enable_private_endpoints ? {
    bypass   = ["AzureServices", "Logging", "Metrics"]
    ip_rules = var.allowed_ip_ranges
  } : null


  # Blob properties
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy = {
      enabled = true
      days    = 30
    }
  }

  # Lifecycle rules for cost optimization (no archive tier for ZRS)
  lifecycle_rules = [
    {
      name    = "archive-inactive-data"
      enabled = true

      filters = {
        blob_types = ["blockBlob"]
      }

      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than = 30
          # Archive tier not supported with ZRS
          delete_after_days_since_modification_greater_than = 365
        }
      }
    }
  ]

  # Identity
  identity = {
    type = "SystemAssigned"
  }

  # Containers for secondary storage
  containers = [
    {
      name                  = "backup-data"
      container_access_type = "private"
    },
    {
      name                  = "replicated-logs"
      container_access_type = "private"
    }
  ]

  tags = merge(var.tags, {
    Environment = "Production"
    Region      = "Secondary"
    Role        = "Backup"
    DR          = "Target"
  })
}

# Disaster Recovery Storage Account (Archive focused)
module "dr_storage" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                = "stdrmultiregionexample"
  resource_group_name = azurerm_resource_group.dr.name
  location            = azurerm_resource_group.dr.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS" # Local redundancy sufficient for DR archive
  access_tier              = "Cool"

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true # Required for Terraform to manage the resource
    allow_nested_items_to_be_public = false
  }

  # Encryption settings
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
  }

  # Network rules - automatically defaults to Deny for security
  # Only specify if you need to allow specific IPs or subnets
  network_rules = var.enable_private_endpoints ? {
    bypass   = ["AzureServices", "Logging", "Metrics"]
    ip_rules = var.allowed_ip_ranges
  } : null


  # Blob properties optimized for archive
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = false # Not needed for archive

    delete_retention_policy = {
      enabled = true
      days    = 90 # Extended retention for DR
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

  # Containers for DR storage
  containers = [
    {
      name                  = "dr-archive"
      container_access_type = "private"
    },
    {
      name                  = "compliance-backup"
      container_access_type = "private"
    }
  ]

  tags = merge(var.tags, {
    Environment = "Production"
    Region      = "DR"
    Role        = "Archive"
    DR          = "Backup"
  })
}

# Storage account for cross-region replication metadata
module "replication_metadata" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                = "strepmetamultiregionex"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS" # Read-access geo-redundant for metadata availability
  access_tier              = "Hot"

  # Enable cross-tenant replication for metadata sync across tenants
  cross_tenant_replication_enabled = true

  # Tables for replication tracking
  tables = [
    { name = "replicationstatus" },
    { name = "replicationlog" }
  ]

  # Queues for replication events
  queues = [
    { name = "replicationevents" },
    { name = "replicationerrors" }
  ]

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true # Required for Terraform to manage the resource
    allow_nested_items_to_be_public = false
  }


  # Containers for replication tracking
  containers = [
    {
      name                  = "replication-logs"
      container_access_type = "private"
    }
  ]

  # Diagnostic settings for metadata monitoring
  monitoring = var.enable_monitoring_alerts ? {
    storage_account = [
      {
        name                       = "diag-metadata"
        log_categories             = ["StorageRead", "StorageWrite", "StorageDelete"]
        metric_categories          = ["Transaction", "Capacity"]
        log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id
      }
    ]
    } : {
    storage_account = []
  }

  tags = merge(var.tags, {
    Environment = "Production"
    Purpose     = "ReplicationMetadata"
    Critical    = "Yes"
  })
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
