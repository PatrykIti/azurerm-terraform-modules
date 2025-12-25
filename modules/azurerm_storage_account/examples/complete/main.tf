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
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
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

  private_endpoint_network_policies = "Disabled"
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
  name                = "law-storage-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# User Assigned Identity for CMK
resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-storage-complete-cmk"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Key Vault for Customer Managed Keys
resource "azurerm_key_vault" "example" {
  name                       = "kv-storage-complete-ex"
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
  source = "../.."

  name                = "stcompleteexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  access_tier              = "Hot"

  # Security settings - Demonstrates all available security options
  security_settings = {
    https_traffic_only_enabled        = true
    min_tls_version                   = "TLS1_2"
    shared_access_key_enabled         = true # Required for Terraform to manage the resource
    allow_nested_items_to_be_public   = false
    infrastructure_encryption_enabled = true
    public_network_access_enabled     = true # Set to false in production
  }

  # New security and compliance parameters from task #18
  default_to_oauth_authentication  = true          # Use OAuth by default in Azure portal
  cross_tenant_replication_enabled = false         # Disable cross-tenant replication for security
  queue_encryption_key_type        = "Account"     # Use account-scoped encryption for queues
  table_encryption_key_type        = "Account"     # Use account-scoped encryption for tables
  allowed_copy_scope               = "PrivateLink" # Restrict copy operations

  # Encryption settings
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
    key_vault_key_id                  = azurerm_key_vault_key.storage.id
    user_assigned_identity_id         = azurerm_user_assigned_identity.storage.id
  }

  # Network security - Allow for initial setup, then restrict
  # Network rules - only specify what should have access
  network_rules = {
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    ip_rules                   = [] # Add your IP ranges here for access
    virtual_network_subnet_ids = [] # Add subnet IDs here for access
    # When both are empty, all public access is denied (secure by default)
  }


  # Identity
  identity = {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }


  # Azure Files Authentication - Enable Kerberos authentication
  azure_files_authentication = {
    directory_type = "AADKERB"
    # For on-premises AD, you would use:
    # directory_type = "AD"
    # active_directory = {
    #   domain_name         = "corp.example.com"
    #   domain_guid         = "12345678-1234-1234-1234-123456789012"
    #   domain_sid          = "S-1-5-21-1234567890-1234567890-1234567890"
    #   storage_sid         = "S-1-5-21-0987654321-0987654321-0987654321"
    #   forest_name         = "corp.example.com"
    #   netbios_domain_name = "CORP"
    # }
  }

  # Blob properties
  blob_properties = {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 365 # Keep change feed for 1 year
    last_access_time_enabled      = true

    delete_retention_policy = {
      enabled = true
      days    = 30
    }

    container_delete_retention_policy = {
      enabled = true
      days    = 30
    }

    restore_policy = {
      days = 29 # Must be less than delete_retention_policy.days
    }

    cors_rules = [{
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT"]
      allowed_origins    = ["https://example.com"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }]
  }

  # Queue properties
  queue_properties = {
    logging = {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 30
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
          tier_to_cool_after_days_since_modification_greater_than = 30
          # Archive tier not supported with ZRS
          delete_after_days_since_modification_greater_than = 365
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
    enabled            = true
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  # Data Lake Gen2 and Protocol Support (new from task #18)
  is_hns_enabled     = false # Hierarchical namespace for Data Lake Gen2
  sftp_enabled       = false # SFTP protocol support (requires HNS)
  nfsv3_enabled      = false # NFSv3 protocol support
  local_user_enabled = false # Local user feature

  # Infrastructure parameters (new from task #18)
  large_file_share_enabled = true # Enable large file shares (>5TB)
  # edge_zone = null # No edge zone deployment for this example

  # Immutability policy configuration (new from task #18)
  immutability_policy = {
    allow_protected_append_writes = true
    state                         = "Unlocked"
    period_since_creation_in_days = 1
  }

  # SAS policy configuration (new from task #18)
  sas_policy = {
    expiration_period = "90.00:00:00" # 90 days in DD.HH:MM:SS format
    expiration_action = "Log"         # Log when SAS tokens expire
  }

  # Routing configuration (new from task #18)
  routing = {
    choice                      = "MicrosoftRouting"
    publish_internet_endpoints  = true
    publish_microsoft_endpoints = true
  }

  # Custom domain configuration (new from task #18)
  # Commented out as it requires a real domain
  # custom_domain = {
  #   name          = "storage.example.com"
  #   use_subdomain = true
  # }

  # Share properties with SMB configuration (new from task #18)
  share_properties = {
    retention_policy = {
      days = 7
    }

    smb = {
      versions                        = ["SMB3.0", "SMB3.1.1"]
      authentication_types            = ["NTLMv2", "Kerberos"]
      kerberos_ticket_encryption_type = ["RC4-HMAC", "AES-256"]
      channel_encryption_type         = ["AES-128-CCM", "AES-128-GCM", "AES-256-GCM"]
      multichannel_enabled            = true
    }

    cors_rule = [{
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT", "DELETE"]
      allowed_origins    = ["https://example.com"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }]
  }

  # Storage containers
  containers = [
    {
      name                  = "data"
      container_access_type = "private"
    },
    {
      name                  = "logs"
      container_access_type = "private"
      metadata = {
        environment = "production"
        retention   = "365days"
      }
    },
    {
      name                  = "backups"
      container_access_type = "private"
    }
  ]

  # Storage queues
  queues = [
    {
      name = "processing-queue"
      metadata = {
        purpose = "async-processing"
      }
    },
    {
      name = "notification-queue"
    }
  ]

  # Storage tables
  tables = [
    {
      name = "auditlog"
    },
    {
      name = "configuration"
    }
  ]

  # File shares
  file_shares = [
    {
      name        = "shared-data"
      quota       = 100
      access_tier = "Hot"
      metadata = {
        department = "engineering"
      }
    },
    {
      name        = "backups"
      quota       = 5120
      access_tier = "Cool"
    }
  ]

  # Diagnostic settings (storage account + blob service)
  diagnostic_settings = [
    {
      name                       = "diag-storage"
      scope                      = "storage_account"
      areas                      = ["transaction", "capacity"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    },
    {
      name                       = "diag-blob"
      scope                      = "blob"
      areas                      = ["read", "write", "delete", "transaction", "capacity"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  ]


  tags = {
    Environment = "Production"
    Example     = "Complete"
    Compliance  = "PCI-DSS"
    DataClass   = "Confidential"
    CostCenter  = "IT-Security"
    Owner       = "Platform Team"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    azurerm_key_vault_key.storage,
    azurerm_private_dns_zone_virtual_network_link.blob,
    azurerm_private_dns_zone_virtual_network_link.file
  ]
}

# Private endpoints for storage services
resource "azurerm_private_endpoint" "blob" {
  name                = "${module.storage_account.name}-pe-blob"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${module.storage_account.name}-psc-blob"
    private_connection_resource_id = module.storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}

resource "azurerm_private_endpoint" "file" {
  name                = "${module.storage_account.name}-pe-file"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${module.storage_account.name}-psc-file"
    private_connection_resource_id = module.storage_account.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.file.id]
  }

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}

resource "azurerm_private_endpoint" "queue" {
  name                = "${module.storage_account.name}-pe-queue"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${module.storage_account.name}-psc-queue"
    private_connection_resource_id = module.storage_account.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.queue.id]
  }

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}

resource "azurerm_private_endpoint" "table" {
  name                = "${module.storage_account.name}-pe-table"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${module.storage_account.name}-psc-table"
    private_connection_resource_id = module.storage_account.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.table.id]
  }

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
