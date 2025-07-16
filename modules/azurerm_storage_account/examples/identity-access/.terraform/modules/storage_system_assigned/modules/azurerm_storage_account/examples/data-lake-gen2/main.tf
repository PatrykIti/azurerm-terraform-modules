terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"
      version = ">= 3.0.0"
    }
    azuread = {
      source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"
      version = ">= 2.0.0"
    }
    random = {
      source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"
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

# Current Azure AD configuration
data "azurerm_client_config" "current" {}

# Service Principal for demonstrating ACLs
resource "azuread_application" "data_engineer" {
  display_name = "sp-datalake-data-engineer-${random_string.suffix.result}"
}

resource "azuread_service_principal" "data_engineer" {
  client_id = azuread_application.data_engineer.client_id
}

# Another Service Principal for demonstrating different ACL permissions
resource "azuread_application" "data_analyst" {
  display_name = "sp-datalake-data-analyst-${random_string.suffix.result}"
}

resource "azuread_service_principal" "data_analyst" {
  client_id = azuread_application.data_analyst.client_id
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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"

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

  # Blob properties with change feed for tracking changes
  blob_properties = {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 7    # Keep change feed for 7 days
    last_access_time_enabled      = true # Track last access time for lifecycle management

    delete_retention_policy = {
      enabled = true
      days    = 30
    }

    container_delete_retention_policy = {
      enabled = true
      days    = 30
    }
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

# Create directory structure within filesystems with ACLs
resource "azurerm_storage_data_lake_gen2_path" "bronze_raw" {
  path               = "raw-data"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.bronze.name
  storage_account_id = module.data_lake_storage.id
  resource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"

  # ACL configuration - Data Engineer has full access, Data Analyst has read-only
  # Access ACL applies to this directory
  ace {
    scope       = "access"
    type        = "user"
    id          = azuread_service_principal.data_engineer.object_id
    permissions = "rwx"
  }

  # Default ACL applies to new items created within this directory
  ace {
    scope       = "default"
    type        = "user"
    id          = azuread_service_principal.data_engineer.object_id
    permissions = "rwx"
  }

  ace {
    scope       = "access"
    type        = "user"
    id          = azuread_service_principal.data_analyst.object_id
    permissions = "r-x"
  }

  ace {
    scope       = "default"
    type        = "user"
    id          = azuread_service_principal.data_analyst.object_id
    permissions = "r-x"
  }
}

resource "azurerm_storage_data_lake_gen2_path" "bronze_staging" {
  path               = "staging"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.bronze.name
  storage_account_id = module.data_lake_storage.id
  resource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"
}

resource "azurerm_storage_data_lake_gen2_path" "silver_processed" {
  path               = "processed"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.silver.name
  storage_account_id = module.data_lake_storage.id
  resource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"
}

resource "azurerm_storage_data_lake_gen2_path" "gold_reports" {
  path               = "reports"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.gold.name
  storage_account_id = module.data_lake_storage.id
  resource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"
}

# Local user for SFTP access
resource "azurerm_storage_account_local_user" "sftp_user" {
  name                 = "sftpuser"
  storage_account_id   = module.data_lake_storage.id
  ssh_key_enabled      = false # Disabled due to SSH key validation issues
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

  # SSH key disabled due to validation issues with AzureRM provider
  # To enable SSH key authentication, uncomment below and provide a valid SSH public key
  # ssh_authorized_key {
  #   description = "Example SSH key for SFTP access"
  #   key         = "ssh-rsa AAAAB3Nza..."
  # }
}

# RBAC Role Assignments for Data Lake
# Storage Blob Data Owner for Data Engineer - full access
resource "azurerm_role_assignment" "data_engineer_owner" {
  scope                = module.data_lake_storage.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.data_engineer.object_id
}

# Storage Blob Data Contributor for Data Analyst - read/write but no ACL management
resource "azurerm_role_assignment" "data_analyst_contributor" {
  scope                = module.data_lake_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.data_analyst.object_id
}

# Storage Blob Data Reader for a specific container
resource "azurerm_role_assignment" "data_analyst_reader_gold" {
  scope                = "${module.data_lake_storage.id}/blobServices/default/containers/${azurerm_storage_data_lake_gen2_filesystem.gold.name}"
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_service_principal.data_analyst.object_id
}

# Give current user Storage Blob Data Owner for testing
resource "azurerm_role_assignment" "current_user_owner" {
  scope                = module.data_lake_storage.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Example directory with specific ACL permissions for a data file location
resource "azurerm_storage_data_lake_gen2_path" "sample_data_dir" {
  path               = "raw-data/samples"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.bronze.name
  storage_account_id = module.data_lake_storage.id
  resource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"

  # File-level ACL - Data Analyst has read-only access to this specific file
  ace {
    scope       = "access"
    type        = "user"
    id          = azuread_service_principal.data_analyst.object_id
    permissions = "r--"
  }

  # Data Engineer has write access
  ace {
    scope       = "access"
    type        = "user"
    id          = azuread_service_principal.data_engineer.object_id
    permissions = "rw-"
  }
}

# ====================================================
# Analytics Service Integration Examples (Commented Out)
# ====================================================
# Uncomment and configure the following resources to integrate with analytics services

# Azure Databricks Integration
# resource "azurerm_databricks_workspace" "example" {
#   name                = "databricks-${random_string.suffix.result}"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   sku                 = "standard"
#   
#   # To mount the Data Lake in Databricks:
#   # 1. Use the service principal credentials created above
#   # 2. Mount using: dbutils.fs.mount(
#   #      source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0",
#   #      mount_point = "/mnt/datalake/bronze",
#   #      extra_configs = {"fs.azure.account.auth.type": "OAuth",
#   #                       "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
#   #                       "fs.azure.account.oauth2.client.id": "<service-principal-client-id>",
#   #                       "fs.azure.account.oauth2.client.secret": "<service-principal-secret>",
#   #                       "fs.azure.account.oauth2.client.endpoint": "https://login.microsoftonline.com/<tenant-id>/oauth2/token"})
# }

# Azure Synapse Analytics Integration
# resource "azurerm_synapse_workspace" "example" {
#   name                                 = "synapse${random_string.suffix.result}"
#   resource_group_name                  = azurerm_resource_group.example.name
#   location                             = azurerm_resource_group.example.location
#   storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.bronze.id
#   sql_administrator_login              = "sqladminuser"
#   sql_administrator_login_password     = "P@ssw0rd123!"
#   
#   identity {
#     type = "SystemAssigned"
#   }
# }
# 
# # Grant Synapse access to the Data Lake
# resource "azurerm_role_assignment" "synapse_storage_access" {
#   scope                = module.data_lake_storage.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_synapse_workspace.example.identity[0].principal_id
# }

# Azure Data Factory Integration
# resource "azurerm_data_factory" "example" {
#   name                = "adf${random_string.suffix.result}"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   
#   identity {
#     type = "SystemAssigned"
#   }
# }
# 
# # Grant Data Factory access to the Data Lake
# resource "azurerm_role_assignment" "adf_storage_access" {
#   scope                = module.data_lake_storage.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_data_factory.example.identity[0].principal_id
# }