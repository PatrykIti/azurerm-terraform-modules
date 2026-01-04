# Core Storage Account Variables
variable "name" {
  description = "The name of the storage account. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be between 3 and 24 characters long and use numbers and lower-case letters only."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Storage Account should exist."
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Valid replication types are LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Valid account kinds are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  }
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool. Premium is only valid for BlockBlobStorage and FileStorage account kinds."
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool", "Premium"], var.access_tier)
    error_message = "Access tier must be 'Hot', 'Cool', or 'Premium'."
  }
}

# Security Settings
variable "security_settings" {
  description = "Security configuration for the storage account."
  type = object({
    https_traffic_only_enabled        = optional(bool, true)
    min_tls_version                   = optional(string, "TLS1_2")
    shared_access_key_enabled         = optional(bool, false)
    allow_nested_items_to_be_public   = optional(bool, false)
    infrastructure_encryption_enabled = optional(bool, true)
    enable_advanced_threat_protection = optional(bool, true)
    public_network_access_enabled     = optional(bool, false)
  })
  default = {}

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.security_settings.min_tls_version)
    error_message = "Valid TLS versions are TLS1_0, TLS1_1, and TLS1_2."
  }
}

# Diagnostic Settings (Storage Account + Services)
variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for the storage account and services (blob/queue/file/table/dfs).

    Each entry creates a separate azurerm_monitor_diagnostic_setting for the selected scope.
    Use areas to group categories (read/write/delete/transaction/capacity) or provide explicit
    log_categories / metric_categories. Entries with no available categories are skipped and
    reported in diagnostic_settings_skipped.
  EOT

  type = list(object({
    name                           = string
    scope                          = optional(string, "storage_account")
    areas                          = optional(list(string))
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
  }))

  default = []

  validation {
    condition = alltrue([
      for scope in distinct([for ds in var.diagnostic_settings : try(ds.scope, "storage_account")]) :
      length([for ds in var.diagnostic_settings : ds if try(ds.scope, "storage_account") == scope]) <= 5
    ])
    error_message = "Azure allows a maximum of 5 diagnostic settings per target resource scope."
  }

  validation {
    condition     = length(distinct([for ds in var.diagnostic_settings : ds.name])) == length(var.diagnostic_settings)
    error_message = "Each diagnostic_settings entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "Each diagnostic_settings entry must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.eventhub_authorization_rule_id == null || (ds.eventhub_name != null && ds.eventhub_name != "")
    ])
    error_message = "eventhub_name is required when eventhub_authorization_rule_id is set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_destination_type == null || contains(["Dedicated", "AzureDiagnostics"], ds.log_analytics_destination_type)
    ])
    error_message = "log_analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      contains(["storage_account", "blob", "queue", "file", "table", "dfs"], try(ds.scope, "storage_account"))
    ])
    error_message = "scope must be one of: storage_account, blob, queue, file, table, dfs."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      alltrue([
        for area in coalescelist(try(ds.areas, null), ["all"]) :
        contains(["all", "read", "write", "delete", "transaction", "capacity", "metrics"], area)
      ])
    ])
    error_message = "areas may contain only: all, read, write, delete, transaction, capacity, metrics."
  }
}

# Network Security
variable "network_rules" {
  description = <<-EOT
    Network access control rules for the storage account.

    When ip_rules or virtual_network_subnet_ids are specified, only those sources will have access (default_action will be "Deny").
    When both are empty/null, all public access will be denied (default_action will be "Deny").

    To allow all public access, set this entire variable to null.

    bypass: Azure services that should bypass network rules (default: ["AzureServices"])
    ip_rules: Set of public IP addresses or CIDR blocks that should have access
    virtual_network_subnet_ids: Set of subnet IDs that should have access via service endpoints
    private_link_access: Private endpoints that should have access
  EOT

  type = object({
    bypass                     = optional(set(string), ["AzureServices"])
    ip_rules                   = optional(set(string), [])
    virtual_network_subnet_ids = optional(set(string), [])
    private_link_access = optional(list(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string)
    })), [])
  })

  default = {
    bypass = ["AzureServices"]
    # Empty ip_rules and virtual_network_subnet_ids means no public access (secure by default)
  }
}

# Azure AD Authentication
variable "azure_files_authentication" {
  description = "Azure Files authentication configuration."
  type = object({
    directory_type = string
    active_directory = optional(object({
      domain_name         = string
      domain_guid         = string
      domain_sid          = string
      storage_sid         = string
      forest_name         = string
      netbios_domain_name = string
    }))
  })
  default = null
}

# Blob Properties with security features
variable "blob_properties" {
  description = "Blob service properties including soft delete and versioning."
  type = object({
    versioning_enabled            = optional(bool, true)
    change_feed_enabled           = optional(bool, true)
    change_feed_retention_in_days = optional(number)
    last_access_time_enabled      = optional(bool, false)
    default_service_version       = optional(string)
    delete_retention_policy = optional(object({
      enabled = optional(bool, true)
      days    = optional(number, 7)
    }), { enabled = true, days = 7 })
    container_delete_retention_policy = optional(object({
      enabled = optional(bool, true)
      days    = optional(number, 7)
    }), { enabled = true, days = 7 })
    restore_policy = optional(object({
      days = number
    }))
    cors_rules = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), [])
  })
  default = {}
}

# Queue Properties with logging
variable "queue_properties" {
  description = "Queue service properties including logging configuration."
  type = object({
    logging = optional(object({
      delete                = optional(bool, true)
      read                  = optional(bool, true)
      write                 = optional(bool, true)
      version               = optional(string, "1.0")
      retention_policy_days = optional(number, 7)
      }), {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    })
  })
  default = {}
}

# Identity configuration
variable "identity" {
  description = "Identity configuration for the storage account."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition = var.identity == null || contains(
      ["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"],
      try(var.identity.type, "")
    )
    error_message = "Identity type must be 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }
}

# Encryption Configuration
variable "encryption" {
  description = "Encryption configuration for the storage account."
  type = object({
    enabled                           = optional(bool, true)
    infrastructure_encryption_enabled = optional(bool, true)
    key_vault_key_id                  = optional(string)
    user_assigned_identity_id         = optional(string)
  })
  default = {
    enabled                           = true
    infrastructure_encryption_enabled = true
  }
}

# Lifecycle Rules
variable "lifecycle_rules" {
  description = "List of lifecycle management rules for the storage account."
  type = list(object({
    name    = string
    enabled = optional(bool, true)
    filters = object({
      blob_types   = list(string)
      prefix_match = optional(list(string), [])
    })
    actions = object({
      base_blob = optional(object({
        tier_to_cool_after_days_since_modification_greater_than        = optional(number)
        tier_to_archive_after_days_since_modification_greater_than     = optional(number)
        delete_after_days_since_modification_greater_than              = optional(number)
        tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number)
        tier_to_archive_after_days_since_last_access_time_greater_than = optional(number)
        delete_after_days_since_last_access_time_greater_than          = optional(number)
      }))
      snapshot = optional(object({
        change_tier_to_archive_after_days_since_creation = optional(number)
        change_tier_to_cool_after_days_since_creation    = optional(number)
        delete_after_days_since_creation_greater_than    = optional(number)
      }))
      version = optional(object({
        change_tier_to_archive_after_days_since_creation = optional(number)
        change_tier_to_cool_after_days_since_creation    = optional(number)
        delete_after_days_since_creation                 = optional(number)
      }))
    })
  }))
  default = []
}

# Storage Containers
variable "containers" {
  description = "List of storage containers to create."
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
    metadata              = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for c in var.containers : contains(["private", "blob", "container"], c.container_access_type)
    ])
    error_message = "Container access type must be 'private', 'blob', or 'container'."
  }
}

# Storage Queues
variable "queues" {
  description = "List of storage queues to create."
  type = list(object({
    name     = string
    metadata = optional(map(string), {})
  }))
  default = []
}

# Storage Tables
variable "tables" {
  description = "List of storage tables to create."
  type = list(object({
    name = string
  }))
  default = []
}

# File Shares
variable "file_shares" {
  description = "List of file shares to create."
  type = list(object({
    name             = string
    quota            = optional(number, 5120)
    access_tier      = optional(string, "Hot")
    enabled_protocol = optional(string, "SMB")
    metadata         = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for fs in var.file_shares : contains(["Hot", "Cool", "TransactionOptimized", "Premium"], fs.access_tier)
    ])
    error_message = "File share access tier must be 'Hot', 'Cool', 'TransactionOptimized', or 'Premium'."
  }
}

# Static Website Configuration
variable "static_website" {
  description = "Static website configuration."
  type = object({
    enabled            = optional(bool, false)
    index_document     = optional(string)
    error_404_document = optional(string)
  })
  default = {}
}

# Immutability Policy Configuration
variable "immutability_policy" {
  description = "Immutability policy configuration for the storage account."
  type = object({
    allow_protected_append_writes = bool
    state                         = string
    period_since_creation_in_days = number
  })
  default = null
}

# SAS Policy Configuration
variable "sas_policy" {
  description = "SAS policy configuration for the storage account."
  type = object({
    expiration_period = string
    expiration_action = optional(string)
  })
  default = null
}

# Data Lake Gen2 and Protocol Support
variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled? This is required for Data Lake Storage Gen 2."
  type        = bool
  default     = null
}

variable "sftp_enabled" {
  description = "Is SFTP enabled for this storage account?"
  type        = bool
  default     = null
}

variable "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled for this storage account?"
  type        = bool
  default     = null
}

variable "local_user_enabled" {
  description = "Is local user feature enabled for this storage account?"
  type        = bool
  default     = null
}

# Infrastructure Parameters
variable "large_file_share_enabled" {
  description = "Is Large File Share Enabled? Defaults to null for backward compatibility."
  type        = bool
  default     = null
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Defaults to null for backward compatibility."
  type        = string
  default     = null
}

# Routing Configuration
variable "routing" {
  description = "Routing configuration for the storage account."
  type = object({
    choice                      = optional(string)
    publish_internet_endpoints  = optional(bool)
    publish_microsoft_endpoints = optional(bool)
  })
  default = null
}

# Custom Domain Configuration
variable "custom_domain" {
  description = "Custom domain configuration for the storage account."
  type = object({
    name          = string
    use_subdomain = optional(bool)
  })
  default = null
}

# Cross-tenant replication
variable "cross_tenant_replication_enabled" {
  description = "Should cross Tenant replication be enabled? Defaults to false."
  type        = bool
  default     = null
}

# OAuth authentication
variable "default_to_oauth_authentication" {
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is false. This will have no effect when the account is not in the same tenant as your Azure subscription."
  type        = bool
  default     = null
}

# Copy scope
variable "allowed_copy_scope" {
  description = "Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are AAD and PrivateLink."
  type        = string
  default     = null

  validation {
    condition     = var.allowed_copy_scope == null || can(regex("^(AAD|PrivateLink)$", var.allowed_copy_scope))
    error_message = "Allowed copy scope must be either 'AAD' or 'PrivateLink'."
  }
}

# Encryption Key Type for Queue
variable "queue_encryption_key_type" {
  description = "The encryption key type to use for the Queue service. Possible values are Service and Account."
  type        = string
  default     = null

  validation {
    condition     = var.queue_encryption_key_type == null || can(regex("^(Service|Account)$", var.queue_encryption_key_type))
    error_message = "Queue encryption key type must be either 'Service', 'Account', or null."
  }
}

# Encryption Key Type for Table
variable "table_encryption_key_type" {
  description = "The encryption key type to use for the Table service. Possible values are Service and Account."
  type        = string
  default     = null

  validation {
    condition     = var.table_encryption_key_type == null || can(regex("^(Service|Account)$", var.table_encryption_key_type))
    error_message = "Table encryption key type must be either 'Service', 'Account', or null."
  }
}

# Share Properties Configuration
variable "share_properties" {
  description = "Share service properties including SMB, retention policy, and CORS rules."
  type = object({
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), [])
    retention_policy = optional(object({
      days = optional(number, 7)
    }))
    smb = optional(object({
      versions                        = optional(list(string), ["SMB3.0", "SMB3.1.1"])
      authentication_types            = optional(list(string), ["NTLMv2", "Kerberos"])
      kerberos_ticket_encryption_type = optional(list(string), ["RC4-HMAC", "AES-256"])
      channel_encryption_type         = optional(list(string), ["AES-128-CCM", "AES-128-GCM", "AES-256-GCM"])
      multichannel_enabled            = optional(bool, false)
    }))
  })
  default = null
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}