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
      purge_soft_delete_on_destroy = false
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

  private_endpoint_network_policies_enabled = false
}

# Log Analytics Workspace for security monitoring
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-storage-secure-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90  # Extended retention for security
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
  sku_name                        = "premium"  # HSM-backed keys
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = []  # Add your management IPs here
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
  key_type     = "RSA-HSM"  # HSM-protected key
  key_size     = 4096       # Maximum key size

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

  account_kind             = "BlockBlobStorage"  # Premium performance
  account_tier             = "Premium"
  account_replication_type = "ZRS"  # Zone redundancy

  # Maximum security settings
  min_tls_version                  = "TLS1_2"
  enable_https_traffic_only        = true
  shared_access_key_enabled        = false  # Enforce Azure AD auth only
  allow_nested_items_to_be_public  = false
  enable_infrastructure_encryption = true
  cross_tenant_replication_enabled = false
  public_network_access_enabled    = false  # Complete network isolation

  # Strict network rules (deny all)
  network_rules = {
    default_action = "Deny"
    bypass         = []  # No bypass, not even for Azure services
    ip_rules       = []  # No public IPs allowed
    virtual_network_subnet_ids = []  # Only private endpoints
  }

  # Private endpoints for all services
  private_endpoints = {
    blob = {
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.storage["blob"].id]
    }
    web = {
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.storage["web"].id]
    }
    dfs = {
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.storage["dfs"].id]
    }
  }

  # Comprehensive monitoring and auditing
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    metrics                    = ["AllMetrics"]
    logs = [
      "StorageRead",
      "StorageWrite",
      "StorageDelete",
      "Transaction",
      "Audit"
    ]
    retention_days = 90
    
    # Additional security monitoring
    enable_data_plane_logging = true
    log_version              = "2.0"
  }

  # Identity configuration
  identity = {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  # Customer Managed Key with HSM
  customer_managed_key = {
    key_vault_key_id          = azurerm_key_vault_key.storage.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  # Blob properties with maximum protection
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    change_feed_retention_in_days = 365  # One year retention
    last_access_time_enabled = true
    
    delete_retention_policy = {
      days = 365  # One year soft delete
    }
    
    container_delete_retention_policy = {
      days = 365  # One year container retention
    }
    
    # Immutability policy default
    default_service_version = "2021-12-02"
    
    # No CORS for security
    cors_rule = []
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

  # Advanced threat protection
  advanced_threat_protection_enabled = true

  # Security tags
  tags = {
    Environment     = "Production"
    SecurityLevel   = "Maximum"
    DataClass       = "Highly Confidential"
    Compliance      = "SOC2,ISO27001,HIPAA"
    EncryptionType  = "Customer-Managed-HSM"
    NetworkAccess   = "Private-Only"
    Authentication  = "Azure-AD-Only"
    Owner           = "Security Team"
    ManagedBy       = "Terraform"
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