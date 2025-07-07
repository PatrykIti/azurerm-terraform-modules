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
  default     = "ZRS"

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

# Network Security
variable "network_rules" {
  description = "Network rules for the storage account."
  type = object({
    default_action             = string
    bypass                     = optional(set(string), ["AzureServices"])
    ip_rules                   = optional(set(string), [])
    virtual_network_subnet_ids = optional(set(string), [])
    private_link_access = optional(list(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string)
    })), [])
  })
  default = {
    default_action = "Deny" # Security by default
    bypass         = ["AzureServices"]
  }

  validation {
    condition     = contains(["Allow", "Deny"], var.network_rules.default_action)
    error_message = "Network rules default action must be either 'Allow' or 'Deny'."
  }
}

# Private Endpoints
variable "private_endpoints" {
  description = "List of private endpoints to create for the storage account."
  type = list(object({
    name                            = string
    subresource_names               = list(string)
    subnet_id                       = string
    private_dns_zone_ids            = optional(list(string), [])
    private_service_connection_name = optional(string)
    is_manual_connection            = optional(bool, false)
    request_message                 = optional(string)
    private_dns_zone_group_name     = optional(string, "default")
    custom_network_interface_name   = optional(string)
    tags                            = optional(map(string), {})
  }))
  default = []
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

# Customer Managed Key
variable "customer_managed_key" {
  description = "Customer managed key configuration for encryption at rest."
  type = object({
    key_vault_key_id          = string
    user_assigned_identity_id = string
  })
  default = null
}

# Diagnostic Settings
variable "diagnostic_settings" {
  description = "Diagnostic settings configuration for audit logging."
  type = object({
    enabled                    = optional(bool, true)
    log_analytics_workspace_id = optional(string)
    storage_account_id         = optional(string)
    eventhub_auth_rule_id      = optional(string)
    logs = optional(object({
      storage_read   = optional(bool, true)
      storage_write  = optional(bool, true)
      storage_delete = optional(bool, true)
      retention_days = optional(number, 7)
    }), {})
    metrics = optional(object({
      transaction    = optional(bool, true)
      capacity       = optional(bool, true)
      retention_days = optional(number, 7)
    }), {})
  })
  default = {
    enabled = false
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
    name         = string
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
    condition = var.allowed_copy_scope == null || contains(["AAD", "PrivateLink"], var.allowed_copy_scope)
    error_message = "Allowed copy scope must be either 'AAD' or 'PrivateLink'."
  }
}

# Encryption Key Type for Queue
variable "queue_encryption_key_type" {
  description = "The encryption key type to use for the Queue service. Possible values are Service and Account."
  type        = string
  default     = null

  validation {
    condition = var.queue_encryption_key_type == null || contains(["Service", "Account"], var.queue_encryption_key_type)
    error_message = "Queue encryption key type must be either 'Service', 'Account', or null."
  }
}

# Encryption Key Type for Table
variable "table_encryption_key_type" {
  description = "The encryption key type to use for the Table service. Possible values are Service and Account."
  type        = string
  default     = null

  validation {
    condition = var.table_encryption_key_type == null || contains(["Service", "Account"], var.table_encryption_key_type)
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