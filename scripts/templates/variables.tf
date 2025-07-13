# Core MODULE_DISPLAY_NAME_PLACEHOLDER Variables
variable "name" {
  description = "The name of the MODULE_TYPE_PLACEHOLDER. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "MODULE_DISPLAY_NAME_PLACEHOLDER name must be between 3 and 24 characters long and use numbers and lower-case letters only."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the MODULE_TYPE_PLACEHOLDER."
  type        = string
}

variable "location" {
  description = "The Azure Region where the MODULE_DISPLAY_NAME_PLACEHOLDER should exist."
  type        = string
}

# TODO: Add specific configuration variables for this resource type
# Example variables based on common Azure resource patterns:

# variable "account_tier" {
#   description = "Defines the Tier to use for this resource. Valid options are Standard and Premium."
#   type        = string
#   default     = "Standard"
#
#   validation {
#     condition     = contains(["Standard", "Premium"], var.account_tier)
#     error_message = "Account tier must be either 'Standard' or 'Premium'."
#   }
# }

# variable "account_replication_type" {
#   description = "Defines the type of replication to use for this resource."
#   type        = string
#   default     = "ZRS"
#
#   validation {
#     condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
#     error_message = "Valid replication types are LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
#   }
# }

# Security Configuration
variable "security_settings" {
  description = "Security configuration for the MODULE_TYPE_PLACEHOLDER."
  type = object({
    https_traffic_only_enabled      = optional(bool, true)
    min_tls_version                 = optional(string, "TLS1_2")
    public_network_access_enabled   = optional(bool, false)
    shared_access_key_enabled       = optional(bool, false)
    allow_nested_items_to_be_public = optional(bool, false)
  })
  default = {
    https_traffic_only_enabled      = true
    min_tls_version                 = "TLS1_2"
    public_network_access_enabled   = false
    shared_access_key_enabled       = false
    allow_nested_items_to_be_public = false
  }

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.security_settings.min_tls_version)
    error_message = "The min_tls_version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

# Network Rules
variable "network_rules" {
  description = "Network rules configuration for the MODULE_TYPE_PLACEHOLDER."
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition     = var.network_rules == null || contains(["Allow", "Deny"], var.network_rules.default_action)
    error_message = "The default_action must be either 'Allow' or 'Deny'."
  }
}

# Private Endpoints
variable "private_endpoints" {
  description = "List of private endpoints to create for the MODULE_TYPE_PLACEHOLDER."
  type = list(object({
    name                            = string
    subnet_id                       = string
    subresource_names               = optional(list(string), ["MODULE_SUBRESOURCE_PLACEHOLDER"])
    private_dns_zone_ids            = optional(list(string), [])
    private_service_connection_name = optional(string)
    is_manual_connection            = optional(bool, false)
    request_message                 = optional(string)
    tags                            = optional(map(string), {})
  }))
  default = []
}

# Diagnostic Settings
variable "diagnostic_settings" {
  description = "Diagnostic settings configuration for audit logging."
  type = object({
    enabled                    = optional(bool, false)
    log_analytics_workspace_id = optional(string)
    storage_account_id         = optional(string)
    eventhub_auth_rule_id      = optional(string)
    logs = optional(object({
      # TODO: Add specific log categories for this resource type
      # Example log categories (update based on actual resource):
      # storage_read     = optional(bool, true)
      # storage_write    = optional(bool, true)
      # storage_delete   = optional(bool, true)
      retention_days = optional(number, 7)
    }), {})
    metrics = optional(object({
      enabled        = optional(bool, true)
      retention_days = optional(number, 7)
    }), {})
  })
  default = {
    enabled = false
  }
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}