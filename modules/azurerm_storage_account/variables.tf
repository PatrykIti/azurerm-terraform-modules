# Core Storage Account Variables
variable "name" {
  description = "The name of the storage account. Must be globally unique."
  type        = string

  validation {
    condition = can(regex("^[a-z0-9]{3,24}$", var.name))
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
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool."
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier must be either 'Hot' or 'Cool'."
  }
}

# Security Variables with secure defaults
variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account."
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Valid TLS versions are TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public."
  type        = bool
  default     = false # Security by default
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key."
  type        = bool
  default     = false # Security by default - prefer Azure AD authentication
}

variable "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled? Changing this forces a new resource to be created."
  type        = bool
  default     = true # Security by default
}

variable "enable_advanced_threat_protection" {
  description = "Should Advanced Threat Protection be enabled for this storage account?"
  type        = bool
  default     = true # Security by default
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
  description = "Map of private endpoints to create. Keys should be subresource names (blob, file, queue, table, web)."
  type = map(object({
    name                 = string
    subnet_id            = string
    private_dns_zone_ids = optional(list(string))
  }))
  default = {}
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
    versioning_enabled  = optional(bool, true) # Security by default
    change_feed_enabled = optional(bool, true) # Security by default
    delete_retention_policy = optional(object({
      days = optional(number, 7) # Security by default
    }), { days = 7 })
    container_delete_retention_policy = optional(object({
      days = optional(number, 7) # Security by default
    }), { days = 7 })
  })
  default = {
    versioning_enabled  = true
    change_feed_enabled = true
    delete_retention_policy = {
      days = 7
    }
    container_delete_retention_policy = {
      days = 7
    }
  }
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
    }))
  })
  default = {
    logging = {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    }
  }
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
      var.identity.type
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
    name                           = string
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string, "Dedicated")
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    logs = list(object({
      category = string
    }))
    metrics = list(object({
      category = string
      enabled  = optional(bool, true)
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