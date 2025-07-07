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
  subscription_id = "df86479f-16c4-4326-984c-14929d7899e3"
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
  name     = "rg-datalake-gen2-example"
  location = "West Europe"
}

# Virtual Network for NFSv3 Support
resource "azurerm_virtual_network" "example" {
  name                = "vnet-datalake-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for NFSv3 Client Access
resource "azurerm_subnet" "nfs_clients" {
  name                 = "snet-nfs-clients"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

# Log Analytics Workspace for diagnostics
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-datalake-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Data Lake Storage Gen2 Account
module "data_lake_storage" {
  source = "../../"

  name                = "datalake${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Storage account configuration for Data Lake Gen2
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  # Enable Data Lake Gen2 features
  is_hns_enabled     = true # Hierarchical Namespace - Required for Data Lake Gen2
  sftp_enabled       = true # Enable SFTP access
  nfsv3_enabled      = true # Enable NFSv3 protocol
  local_user_enabled = true # Enable local users for SFTP

  # Security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = true # Required for Terraform to manage containers
    allow_nested_items_to_be_public = false
  }

  # Network configuration for NFSv3
  network_rules = {
    default_action             = "Allow" # Required for initial setup
    bypass                     = ["AzureServices"]
    ip_rules                   = [] # Add your client IP ranges here
    virtual_network_subnet_ids = [azurerm_subnet.nfs_clients.id]
  }

  # Enable system-assigned identity for secure operations
  identity = {
    type = "SystemAssigned"
  }

  # Monitoring configuration
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    logs = {
      storage_read   = true
      storage_write  = true
      storage_delete = true
    }
    metrics = {
      transaction = true
      capacity    = true
    }
  }

  # Lifecycle management for data lake
  lifecycle_rules = [
    {
      name    = "archive-old-data"
      enabled = true

      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["raw-data/"]
      }

      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than    = 30
          tier_to_archive_after_days_since_modification_greater_than = 90
          delete_after_days_since_modification_greater_than          = 365
        }
      }
    },
    {
      name    = "cleanup-temp-data"
      enabled = true

      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["temp/", "staging/"]
      }

      actions = {
        base_blob = {
          delete_after_days_since_modification_greater_than = 7
        }
      }
    }
  ]

  # Tags
  tags = {
    Environment = "Production"
    Type        = "DataLake"
    Example     = "Data-Lake-Gen2"
    Features    = "HNS,SFTP,NFSv3"
    ManagedBy   = "Terraform"
  }
}

# Data Lake Containers with hierarchical structure
resource "azurerm_storage_data_lake_gen2_filesystem" "bronze" {
  name               = "bronze"
  storage_account_id = module.data_lake_storage.id

  properties = {
    layer       = "bronze"
    description = "Raw data ingestion layer"
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "silver" {
  name               = "silver"
  storage_account_id = module.data_lake_storage.id

  properties = {
    layer       = "silver"
    description = "Cleaned and validated data layer"
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gold" {
  name               = "gold"
  storage_account_id = module.data_lake_storage.id

  properties = {
    layer       = "gold"
    description = "Business-ready aggregated data layer"
  }
}

# Create directory structure within filesystems
resource "azurerm_storage_data_lake_gen2_path" "bronze_raw" {
  path               = "raw-data"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.bronze.name
  storage_account_id = module.data_lake_storage.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "bronze_staging" {
  path               = "staging"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.bronze.name
  storage_account_id = module.data_lake_storage.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "silver_processed" {
  path               = "processed"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.silver.name
  storage_account_id = module.data_lake_storage.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "gold_reports" {
  path               = "reports"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.gold.name
  storage_account_id = module.data_lake_storage.id
  resource           = "directory"
}

# Local user for SFTP access
resource "azurerm_storage_account_local_user" "sftp_user" {
  name                 = "sftpuser"
  storage_account_id   = module.data_lake_storage.id
  ssh_key_enabled      = true
  ssh_password_enabled = true

  permission_scope {
    permissions {
      read   = true
      write  = true
      delete = true
      list   = true
      create = true
    }

    service       = "blob"
    resource_name = azurerm_storage_data_lake_gen2_filesystem.bronze.name
  }

  permission_scope {
    permissions {
      read   = true
      write  = false
      delete = false
      list   = true
      create = false
    }

    service       = "blob"
    resource_name = azurerm_storage_data_lake_gen2_filesystem.silver.name
  }

  ssh_authorized_key {
    description = "Example SSH key for SFTP access"
    key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+... example@local"
  }
}