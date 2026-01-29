variable "name" {
  description = "The name of the Log Analytics Workspace."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{2,61}[A-Za-z0-9]$", var.name))
    error_message = "Log Analytics Workspace name must be 4-63 characters, alphanumeric or hyphens, and cannot start/end with a hyphen."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Log Analytics Workspace."
  type        = string
}

variable "location" {
  description = "The Azure region where the Log Analytics Workspace should exist."
  type        = string
}

variable "sku" {
  description = "The SKU for the Log Analytics Workspace."
  type        = string
  default     = "PerGB2018"

  validation {
    condition = contains([
      "Free",
      "PerNode",
      "Premium",
      "Standalone",
      "Standard",
      "Unlimited",
      "CapacityReservation",
      "PerGB2018"
    ], var.sku)
    error_message = "sku must be one of: Free, PerNode, Premium, Standalone, Standard, Unlimited, CapacityReservation, PerGB2018."
  }
}

variable "retention_in_days" {
  description = "The retention period for data stored in the Log Analytics Workspace."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 7 && var.retention_in_days <= 730
    error_message = "retention_in_days must be between 7 and 730."
  }
}

variable "daily_quota_gb" {
  description = "Daily data ingestion cap in GB. Use -1 for unlimited or null to use provider defaults."
  type        = number
  default     = null

  validation {
    condition     = var.daily_quota_gb == null || var.daily_quota_gb == -1 || var.daily_quota_gb > 0
    error_message = "daily_quota_gb must be -1 (unlimited), null, or a positive number."
  }
}

variable "reservation_capacity_in_gb_per_day" {
  description = "Reserved capacity in GB per day for CapacityReservation SKU."
  type        = number
  default     = null

  validation {
    condition     = var.reservation_capacity_in_gb_per_day == null || var.reservation_capacity_in_gb_per_day > 0
    error_message = "reservation_capacity_in_gb_per_day must be a positive number when set."
  }

  validation {
    condition     = var.reservation_capacity_in_gb_per_day == null || var.sku == "CapacityReservation"
    error_message = "reservation_capacity_in_gb_per_day can only be set when sku is CapacityReservation."
  }
}

variable "internet_ingestion_enabled" {
  description = "Whether data ingestion from the internet is enabled."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether queries from the internet are enabled."
  type        = bool
  default     = true
}

variable "local_authentication_enabled" {
  description = "Whether local (workspace key) authentication is enabled."
  type        = bool
  default     = true
}

variable "allow_resource_only_permissions" {
  description = "Whether to allow resource-only permissions for the workspace."
  type        = bool
  default     = null
}

variable "identity" {
  description = "Managed identity configuration for the Log Analytics Workspace."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.identity == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.identity.type)
    error_message = "identity.type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }

  validation {
    condition = var.identity == null || !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) || length(var.identity.identity_ids) > 0
    error_message = "identity.identity_ids must be provided when identity.type includes UserAssigned."
  }
}

variable "solutions" {
  description = "Log Analytics solutions to deploy in the workspace."
  type = list(object({
    name = string
    plan = object({
      publisher       = string
      product         = string
      promotion_code  = optional(string)
    })
    tags = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = length(distinct([for s in var.solutions : s.name])) == length(var.solutions)
    error_message = "solutions names must be unique."
  }
}

variable "data_export_rules" {
  description = "Data export rules for the workspace."
  type = list(object({
    name                    = string
    destination_resource_id = string
    table_names             = list(string)
    enabled                 = optional(bool, true)
  }))
  default = []

  validation {
    condition     = length(distinct([for r in var.data_export_rules : r.name])) == length(var.data_export_rules)
    error_message = "data_export_rules names must be unique."
  }

  validation {
    condition = alltrue([
      for r in var.data_export_rules : length(r.table_names) > 0
    ])
    error_message = "data_export_rules.table_names must contain at least one table."
  }
}

variable "windows_event_datasources" {
  description = "Windows Event Log data sources."
  type = list(object({
    name           = string
    event_log_name = string
    event_types    = list(string)
  }))
  default = []

  validation {
    condition     = length(distinct([for ds in var.windows_event_datasources : ds.name])) == length(var.windows_event_datasources)
    error_message = "windows_event_datasources names must be unique."
  }

  validation {
    condition = alltrue([
      for ds in var.windows_event_datasources : ds.event_log_name != "" && length(ds.event_types) > 0
    ])
    error_message = "windows_event_datasources require event_log_name and at least one event_type."
  }
}

variable "windows_performance_counters" {
  description = "Windows Performance Counter data sources."
  type = list(object({
    name             = string
    object_name      = string
    instance_name    = string
    counter_name     = string
    interval_seconds = number
  }))
  default = []

  validation {
    condition     = length(distinct([for ds in var.windows_performance_counters : ds.name])) == length(var.windows_performance_counters)
    error_message = "windows_performance_counters names must be unique."
  }

  validation {
    condition = alltrue([
      for ds in var.windows_performance_counters : ds.interval_seconds > 0
    ])
    error_message = "windows_performance_counters.interval_seconds must be greater than 0."
  }
}

variable "storage_insights" {
  description = "Storage insights configurations for the workspace."
  type = list(object({
    name                 = string
    storage_account_id   = string
    storage_account_key  = string
    blob_container_names = optional(list(string))
    table_names          = optional(list(string))
  }))
  default = []

  validation {
    condition     = length(distinct([for si in var.storage_insights : si.name])) == length(var.storage_insights)
    error_message = "storage_insights names must be unique."
  }
}

variable "linked_services" {
  description = "Linked services for the workspace (e.g., Automation Account)."
  type = list(object({
    name            = string
    read_access_id  = string
    write_access_id = optional(string)
  }))
  default = []

  validation {
    condition     = length(distinct([for ls in var.linked_services : ls.name])) == length(var.linked_services)
    error_message = "linked_services names must be unique."
  }
}

variable "clusters" {
  description = "Log Analytics clusters to create."
  type = list(object({
    name                = string
    location            = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string), {})
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }))
  }))
  default = []

  validation {
    condition     = length(distinct([for c in var.clusters : c.name])) == length(var.clusters)
    error_message = "clusters names must be unique."
  }

  validation {
    condition = alltrue([
      for c in var.clusters :
      try(c.identity, null) == null || contains([
        "SystemAssigned",
        "UserAssigned",
        "SystemAssigned, UserAssigned"
      ], c.identity.type)
    ])
    error_message = "clusters.identity.type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }

  validation {
    condition = alltrue([
      for c in var.clusters :
      try(c.identity, null) == null || !contains(["UserAssigned", "SystemAssigned, UserAssigned"], c.identity.type) || length(try(c.identity.identity_ids, [])) > 0
    ])
    error_message = "clusters.identity.identity_ids must be provided when identity.type includes UserAssigned."
  }
}

variable "cluster_customer_managed_keys" {
  description = "Customer managed keys for Log Analytics clusters."
  type = list(object({
    name                     = string
    log_analytics_cluster_id = optional(string)
    cluster_name             = optional(string)
    key_vault_key_id         = string
  }))
  default = []

  validation {
    condition     = length(distinct([for cmk in var.cluster_customer_managed_keys : cmk.name])) == length(var.cluster_customer_managed_keys)
    error_message = "cluster_customer_managed_keys names must be unique."
  }

  validation {
    condition = alltrue([
      for cmk in var.cluster_customer_managed_keys :
      (try(cmk.log_analytics_cluster_id, null) != null && try(cmk.log_analytics_cluster_id, "") != "") ||
      (try(cmk.cluster_name, null) != null && cmk.cluster_name != "")
    ])
    error_message = "cluster_customer_managed_keys require log_analytics_cluster_id or cluster_name."
  }

  validation {
    condition = alltrue([
      for cmk in var.cluster_customer_managed_keys :
      try(cmk.cluster_name, null) == null || contains([for c in var.clusters : c.name], cmk.cluster_name)
    ])
    error_message = "cluster_customer_managed_keys.cluster_name must reference a cluster defined in clusters."
  }
}

variable "monitoring" {
  description = <<-EOT
    Monitoring configuration for Log Analytics Workspace diagnostics.

    Diagnostic settings for logs and metrics. Provide explicit log_categories
    and/or metric_categories and at least one destination (Log Analytics,
    Storage, or Event Hub).
  EOT

  type = list(object({
    name                           = string
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
  }))

  nullable = false
  default  = []

  validation {
    condition     = length(var.monitoring) <= 5
    error_message = "Azure allows a maximum of 5 diagnostic settings per workspace."
  }

  validation {
    condition     = length(distinct([for ds in var.monitoring : ds.name])) == length(var.monitoring)
    error_message = "Each monitoring entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for ds in var.monitoring :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "Each monitoring entry must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
  }

  validation {
    condition = alltrue([
      for ds in var.monitoring :
      ds.eventhub_authorization_rule_id == null || (ds.eventhub_name != null && ds.eventhub_name != "")
    ])
    error_message = "eventhub_name is required when eventhub_authorization_rule_id is set."
  }

  validation {
    condition = alltrue([
      for ds in var.monitoring :
      ds.log_analytics_destination_type == null || contains(["Dedicated", "AzureDiagnostics"], ds.log_analytics_destination_type)
    ])
    error_message = "log_analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }

  validation {
    condition = alltrue([
      for ds in var.monitoring :
      alltrue([for c in(ds.log_categories == null ? [] : ds.log_categories) : c != ""]) &&
      alltrue([for c in(ds.metric_categories == null ? [] : ds.metric_categories) : c != ""])
    ])
    error_message = "log_categories and metric_categories must not contain empty strings."
  }
}

variable "timeouts" {
  description = "Optional timeouts configuration for Log Analytics Workspace."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
    read   = optional(string)
  })
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
