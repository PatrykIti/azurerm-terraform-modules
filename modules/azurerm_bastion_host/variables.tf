variable "name" {
  description = "The name of the Bastion Host."
  type        = string

  validation {
    condition     = can(regex("^(?:[A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9_.-]{0,78}[A-Za-z0-9_])$", var.name))
    error_message = "Bastion Host name must be 1-80 characters, start with a letter or number, contain only letters, numbers, underscores, periods, or hyphens, and end with a letter, number, or underscore."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Bastion Host."
  type        = string
}

variable "location" {
  description = "The Azure region where the Bastion Host should exist."
  type        = string
}

variable "sku" {
  description = "The SKU of the Bastion Host. Possible values are Developer, Basic, Standard, and Premium."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Developer", "Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Developer, Basic, Standard, Premium."
  }
}

variable "scale_units" {
  description = "The number of scale units for the Bastion Host (2-50). Only supported with Standard or Premium SKU."
  type        = number
  default     = null
  nullable    = true

  validation {
    condition     = var.scale_units == null || (var.scale_units >= 2 && var.scale_units <= 50)
    error_message = "scale_units must be between 2 and 50 when specified."
  }
}

variable "ip_configuration" {
  description = "IP configuration for the Bastion Host (required for Basic/Standard/Premium)."
  type = list(object({
    name                 = string
    subnet_id            = string
    public_ip_address_id = string
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(var.ip_configuration) <= 1
    error_message = "ip_configuration supports at most one entry."
  }

  validation {
    condition     = length(distinct([for cfg in var.ip_configuration : cfg.name])) == length(var.ip_configuration)
    error_message = "ip_configuration names must be unique."
  }

  validation {
    condition = alltrue([
      for cfg in var.ip_configuration :
      cfg.name != "" && cfg.subnet_id != "" && cfg.public_ip_address_id != ""
    ])
    error_message = "ip_configuration requires non-empty name, subnet_id, and public_ip_address_id."
  }

  validation {
    condition = alltrue([
      for cfg in var.ip_configuration :
      can(regex("(?i)/subnets/AzureBastionSubnet$", cfg.subnet_id))
    ])
    error_message = "ip_configuration.subnet_id must reference the AzureBastionSubnet subnet."
  }
}

variable "virtual_network_id" {
  description = "The ID of the Virtual Network for the Developer Bastion Host."
  type        = string
  default     = null
  nullable    = true
}

variable "copy_paste_enabled" {
  description = "Is Copy/Paste enabled for the Bastion Host?"
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "Is File Copy enabled for the Bastion Host? Supported on Standard or Premium SKU only."
  type        = bool
  default     = false
}

variable "ip_connect_enabled" {
  description = "Is IP Connect enabled for the Bastion Host? Supported on Standard or Premium SKU only."
  type        = bool
  default     = false
}

variable "shareable_link_enabled" {
  description = "Is Shareable Link enabled for the Bastion Host? Supported on Standard or Premium SKU only."
  type        = bool
  default     = false
}

variable "tunneling_enabled" {
  description = "Is Tunneling enabled for the Bastion Host? Supported on Standard or Premium SKU only."
  type        = bool
  default     = false
}

variable "session_recording_enabled" {
  description = "Is Session Recording enabled for the Bastion Host? Supported on Premium SKU only."
  type        = bool
  default     = false
}

variable "kerberos_enabled" {
  description = "Is Kerberos authentication enabled for the Bastion Host? Supported on Standard or Premium SKU only."
  type        = bool
  default     = false
}

variable "zones" {
  description = "A list of Availability Zones in which this Bastion Host should be located."
  type        = list(string)
  default     = null
  nullable    = true

  validation {
    condition     = var.zones == null || alltrue([for zone in var.zones : zone != ""])
    error_message = "zones must not contain empty strings."
  }
}

variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for the Bastion Host.

    Provide either log_categories/metric_categories or areas to select categories.
    If neither is provided, areas defaults to ["all"].
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
    error_message = "Azure allows a maximum of 5 diagnostic settings per Bastion Host."
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
      alltrue([for area in coalesce(ds.areas, []) : contains(["all", "logs", "metrics", "audit"], area)])
    ])
    error_message = "areas may only include: all, logs, metrics, audit."
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
  description = "Custom timeouts for the Bastion Host resource."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the Bastion Host."
  type        = map(string)
  default     = {}
}
