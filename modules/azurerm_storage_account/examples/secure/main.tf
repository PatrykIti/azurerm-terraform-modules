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
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
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
  name     = "rg-storage-secure-example"
  location = "West Europe"
}

# Virtual Network for complete isolation
resource "azurerm_virtual_network" "example" {
  name                = "vnet-storage-secure"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for Private Endpoints only
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

# Log Analytics Workspace for security monitoring
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-storage-secure-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90 # Extended retention for security
}

# User Assigned Identity for CMK
resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-storage-secure-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Key Vault with enhanced security
resource "azurerm_key_vault" "example" {
  name                            = "kv-sec-${random_string.suffix.result}"
  location                        = azurerm_resource_group.example.location
  resource_group_name             = azurerm_resource_group.example.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "premium" # HSM-backed keys
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [] # Add your management IPs here
  }

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

# Key for Storage Encryption with rotation
resource "azurerm_key_vault_key" "storage" {
  name         = "storage-encryption-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA-HSM" # HSM-protected key
  key_size     = 4096      # Maximum key size

  key_opts = [
    "decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    expire_after         = "P365D"
    notify_before_expiry = "P30D"
  }

  depends_on = [azurerm_key_vault.example]
}

# Private DNS Zones for all storage services
resource "azurerm_private_dns_zone" "storage" {
  for_each = toset(["blob", "file", "queue", "table", "web", "dfs"])

  name                = "privatelink.${each.key}.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# Link DNS zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  for_each = azurerm_private_dns_zone.storage

  name                  = "${each.key}-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Current client configuration
data "azurerm_client_config" "current" {}

# Highly secure Storage Account
module "storage_account" {
  source = "../../"

  name                = "stsecure${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  account_kind             = "BlockBlobStorage" # Premium performance
  account_tier             = "Premium"
  account_replication_type = "ZRS" # Zone redundancy

  # Maximum security settings
  security_settings = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    shared_access_key_enabled       = false # Disabled for OAuth authentication only
    allow_nested_items_to_be_public = false
    public_network_access_enabled   = false # Completely disable public network access
  }
  
  # Additional security parameters for OAuth and copy restrictions
  default_to_oauth_authentication  = true
  allowed_copy_scope               = "PrivateLink"
  cross_tenant_replication_enabled = false
  queue_encryption_key_type        = "Account"
  table_encryption_key_type        = "Account"

  # Additional encryption settings
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
    key_vault_key_id                  = azurerm_key_vault_key.storage.id
    user_assigned_identity_id         = azurerm_user_assigned_identity.storage.id
  }

  # Strict network rules (deny all)
  network_rules = {
    default_action             = "Deny"
    bypass                     = [] # No bypass, not even for Azure services
    ip_rules                   = [] # No public IPs allowed
    virtual_network_subnet_ids = [] # Only private endpoints
  }

  # Private endpoints for all services
  private_endpoints = [
    {
      name                 = "blob"
      subresource_names    = ["blob"]
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.storage["blob"].id]
    },
    {
      name                 = "web"
      subresource_names    = ["web"]
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.storage["web"].id]
    },
    {
      name                 = "dfs"
      subresource_names    = ["dfs"]
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.storage["dfs"].id]
    }
  ]

  # Comprehensive monitoring and auditing
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

  # Identity configuration
  identity = {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }


  # Blob properties with maximum protection
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
    default_service_version  = "2021-12-02"

    delete_retention_policy = {
      enabled = true
      days    = 365 # One year soft delete
    }

    container_delete_retention_policy = {
      enabled = true
      days    = 365 # One year container retention
    }

    cors_rules = [] # No CORS for security
  }

  # Lifecycle rules for compliance
  lifecycle_rules = [
    {
      name    = "compliance-retention"
      enabled = true

      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = ["audit/", "compliance/"]
      }

      actions = {
        base_blob = {
          # Never delete compliance data
          tier_to_cool_after_days_since_modification_greater_than    = 90
          tier_to_archive_after_days_since_modification_greater_than = 365
        }
      }
    }
  ]

  # SAS policy configuration for defense in depth
  # Even though shared access keys are disabled, configure SAS policy
  sas_policy = {
    expiration_period = "01.00:00:00" # 1 day maximum SAS token validity
    expiration_action = "Log"         # Log when SAS tokens expire
  }

  # Storage containers with immutability policies
  containers = {
    "compliance-data" = {
      public_access = "None"
      
      # Immutability policy for regulatory compliance
      immutability_policy = {
        immutability_period_in_days           = 365
        immutability_period_state             = "Unlocked" # Can be changed to "Locked" after testing
        allow_protected_append_writes_all_enabled = false
      }
      
      metadata = {
        purpose    = "Compliance data storage"
        retention  = "7years"
        compliance = "WORM"
      }
    }
    
    "audit-logs" = {
      public_access = "None"
      metadata = {
        purpose   = "Security audit logs"
        retention = "365days"
      }
    }
  }

  # Security tags
  tags = {
    Environment    = "Production"
    SecurityLevel  = "Maximum"
    DataClass      = "Highly Confidential"
    Compliance     = "SOC2,ISO27001,HIPAA"
    EncryptionType = "Customer-Managed-HSM"
    NetworkAccess  = "Private-Only"
    Authentication = "Azure-AD-Only"
    Owner          = "Security Team"
    ManagedBy      = "Terraform"
  }

  depends_on = [
    azurerm_key_vault_key.storage,
    azurerm_private_dns_zone_virtual_network_link.storage
  ]
}

# Security Alert for storage account
resource "azurerm_monitor_metric_alert" "storage_auth_failures" {
  name                = "alert-storage-auth-failures"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [module.storage_account.id]
  description         = "Alert on authentication failures"
  severity            = 1

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 5

    dimension {
      name     = "ResponseType"
      operator = "Include"
      values   = ["AuthenticationFailed"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.security.id
  }
}

# Action group for security alerts
resource "azurerm_monitor_action_group" "security" {
  name                = "ag-storage-security"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "security"

  email_receiver {
    name                    = "security-team"
    email_address           = "security@example.com"
    use_common_alert_schema = true
  }
}