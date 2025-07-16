#------------------------------------------------------------------------------
# Required Variables
#------------------------------------------------------------------------------
variable "name" {
  description = "The name of the MODULE_TYPE_PLACEHOLDER. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "The name must be between 3 and 63 characters, start and end with a letter or number, and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the MODULE_TYPE_PLACEHOLDER."
  type        = string
}

variable "location" {
  description = "The Azure Region where the MODULE_TYPE_PLACEHOLDER should exist. Changing this forces a new resource to be created."
  type        = string
}

#------------------------------------------------------------------------------
# Optional Variables - General
#------------------------------------------------------------------------------
variable "name_prefix" {
  description = "Optional prefix for the MODULE_TYPE_PLACEHOLDER name."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

#------------------------------------------------------------------------------
# Optional Variables - Configuration
#------------------------------------------------------------------------------
# TODO: Add module-specific configuration variables

#------------------------------------------------------------------------------
# Optional Variables - Security
#------------------------------------------------------------------------------
variable "enable_https_traffic_only" {
  description = "Boolean flag which forces HTTPS if enabled. Defaults to true."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum supported TLS version. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2."
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "The min_tls_version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

#------------------------------------------------------------------------------
# Optional Variables - Networking
#------------------------------------------------------------------------------
variable "network_rules" {
  description = "Network rules configuration for the MODULE_TYPE_PLACEHOLDER."
  type = object({
    default_action             = string
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  validation {
    condition     = contains(["Allow", "Deny"], var.network_rules.default_action)
    error_message = "The default_action must be either 'Allow' or 'Deny'."
  }
}

variable "private_endpoints" {
  description = "List of private endpoints to create for the MODULE_TYPE_PLACEHOLDER."
  type = list(object({
    name                            = string
    subnet_id                       = string
    subresource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"])
    private_dns_zone_ids            = optional(list(string), [])
    private_service_connection_name = optional(string)
    is_manual_connection            = optional(bool, false)
    request_message                 = optional(string)
    tags                            = optional(map(string), {})
  }))
  default = []
}

#------------------------------------------------------------------------------
# Optional Variables - Monitoring
#------------------------------------------------------------------------------
variable "diagnostic_settings" {
  description = "Diagnostic settings configuration for audit logging."
  type = object({
    enabled                    = optional(bool, true)
    log_analytics_workspace_id = optional(string)
    storage_account_id         = optional(string)
    eventhub_auth_rule_id      = optional(string)
    logs = optional(object({
      # TODO: Add specific log categories for this resource type
      category_1     = optional(bool, true)
      category_2     = optional(bool, true)
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