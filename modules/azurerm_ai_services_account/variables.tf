# Core configuration
variable "name" {
  description = "The name of the AI Services Account."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{1,62}[A-Za-z0-9]$", var.name))
    error_message = "name must be 2-64 characters long, start/end with an alphanumeric character, and contain only letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the AI Services Account."
  type        = string
}

variable "location" {
  description = "The Azure region where the AI Services Account should exist."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the AI Services Account."
  type        = string

  validation {
    condition = contains(
      ["F0", "F1", "S0", "S", "S1", "S2", "S3", "S4", "S5", "S6", "P0", "P1", "P2", "E0", "DC0"],
      var.sku_name
    )
    error_message = "sku_name must be one of: F0, F1, S0, S, S1, S2, S3, S4, S5, S6, P0, P1, P2, E0, DC0."
  }
}

# Network + authentication
variable "custom_subdomain_name" {
  description = "Custom subdomain name used for token-based authentication. Required when network_acls is specified."
  type        = string
  default     = null

  validation {
    condition     = var.custom_subdomain_name == null || var.custom_subdomain_name != ""
    error_message = "custom_subdomain_name must not be an empty string."
  }
}

variable "fqdns" {
  description = "List of FQDNs allowed for the AI Services Account."
  type        = list(string)
  default     = null

  validation {
    condition     = var.fqdns == null || alltrue([for fqdn in var.fqdns : fqdn != ""])
    error_message = "fqdns must not contain empty strings."
  }
}

variable "public_network_access" {
  description = "Whether public network access is allowed for the AI Services Account. Possible values: Enabled, Disabled."
  type        = string
  default     = "Enabled"

  validation {
    condition     = var.public_network_access == null || contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "public_network_access must be either Enabled or Disabled."
  }
}

variable "local_authentication_enabled" {
  description = "Whether local authentication is enabled for the AI Services Account."
  type        = bool
  default     = true
}

variable "outbound_network_access_restricted" {
  description = "Whether outbound network access is restricted for the AI Services Account."
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Network ACL configuration for the AI Services Account."
  type = object({
    default_action = string
    bypass         = optional(string, "AzureServices")
    ip_rules       = optional(list(string))
    virtual_network_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })))
  })
  default = null

  validation {
    condition     = var.network_acls == null || contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "network_acls.default_action must be either Allow or Deny."
  }

  validation {
    condition     = var.network_acls == null || contains(["None", "AzureServices"], var.network_acls.bypass)
    error_message = "network_acls.bypass must be either None or AzureServices."
  }

  validation {
    condition = var.network_acls == null || alltrue([
      for rule in coalesce(var.network_acls.virtual_network_rules, []) :
      rule.subnet_id != ""
    ])
    error_message = "network_acls.virtual_network_rules subnet_id must not be empty."
  }

  validation {
    condition     = var.network_acls == null || alltrue([for ip in coalesce(var.network_acls.ip_rules, []) : ip != ""])
    error_message = "network_acls.ip_rules must not contain empty strings."
  }
}

# Identity + encryption
variable "identity" {
  description = "Managed identity configuration for the AI Services Account."
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
    error_message = "identity.type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }

  validation {
    condition = var.identity == null || (
      !strcontains(lower(var.identity.type), "userassigned") ||
      (var.identity.identity_ids != null && length(var.identity.identity_ids) > 0)
    )
    error_message = "identity.identity_ids is required when identity.type includes UserAssigned."
  }
}

variable "customer_managed_key" {
  description = "Customer-managed key configuration for encryption at rest."
  type = object({
    key_vault_key_id   = optional(string)
    managed_hsm_key_id = optional(string)
    identity_client_id = optional(string)
  })
  default = null

  validation {
    condition = var.customer_managed_key == null || (
      (var.customer_managed_key.key_vault_key_id != null ? 1 : 0) +
      (var.customer_managed_key.managed_hsm_key_id != null ? 1 : 0)
    ) == 1
    error_message = "customer_managed_key requires exactly one of key_vault_key_id or managed_hsm_key_id."
  }
}

variable "storage" {
  description = "Optional storage configuration blocks for the AI Services Account."
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = alltrue([for entry in var.storage : entry.storage_account_id != ""])
    error_message = "storage.storage_account_id must not be empty."
  }
}

# Diagnostics
variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for the AI Services Account.

    Provide explicit log_categories and/or metric_categories, or use areas to map to
    available diagnostic categories. If neither is provided, areas defaults to ["all"].
  EOT

  type = list(object({
    name                           = string
    areas                          = optional(list(string))
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(var.diagnostic_settings) <= 5
    error_message = "Azure allows a maximum of 5 diagnostic settings per AI Services Account."
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
      alltrue([for c in(ds.log_categories == null ? [] : ds.log_categories) : c != ""]) &&
      alltrue([for c in(ds.metric_categories == null ? [] : ds.metric_categories) : c != ""]) &&
      alltrue([for c in(ds.areas == null ? [] : ds.areas) : c != ""])
    ])
    error_message = "log_categories, metric_categories, and areas must not contain empty strings."
  }
}

variable "timeouts" {
  description = "Custom timeouts for the AI Services Account."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the AI Services Account."
  type        = map(string)
  default     = {}
}
