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

variable "workspace" {
  description = <<-EOT
    Core Log Analytics Workspace settings.

    sku: SKU for the workspace (e.g. PerGB2018).
    retention_in_days: Data retention period.
    daily_quota_gb: Daily ingestion cap in GB (-1 for unlimited).
    reservation_capacity_in_gb_per_day: Reserved capacity (only for CapacityReservation).
    internet_ingestion_enabled: Allow public ingestion.
    internet_query_enabled: Allow public query.
    local_authentication_enabled: Allow local (workspace key) authentication.
    allow_resource_only_permissions: Allow resource-only permissions.
    timeouts: Optional custom timeouts.
  EOT

  type = object({
    sku                                = optional(string, "PerGB2018")
    retention_in_days                  = optional(number, 30)
    daily_quota_gb                     = optional(number)
    reservation_capacity_in_gb_per_day = optional(number)
    internet_ingestion_enabled         = optional(bool, true)
    internet_query_enabled             = optional(bool, true)
    local_authentication_enabled       = optional(bool, true)
    allow_resource_only_permissions    = optional(bool)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
      read   = optional(string)
    }))
  })

  nullable = false
  default  = {}

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
    ], var.workspace.sku)
    error_message = "workspace.sku must be one of: Free, PerNode, Premium, Standalone, Standard, Unlimited, CapacityReservation, PerGB2018."
  }

  validation {
    condition     = var.workspace.retention_in_days >= 7 && var.workspace.retention_in_days <= 730
    error_message = "workspace.retention_in_days must be between 7 and 730."
  }

  validation {
    condition     = var.workspace.daily_quota_gb == null || var.workspace.daily_quota_gb == -1 || var.workspace.daily_quota_gb > 0
    error_message = "workspace.daily_quota_gb must be -1 (unlimited), null, or a positive number."
  }

  validation {
    condition     = var.workspace.reservation_capacity_in_gb_per_day == null || var.workspace.reservation_capacity_in_gb_per_day > 0
    error_message = "workspace.reservation_capacity_in_gb_per_day must be a positive number when set."
  }

  validation {
    condition     = var.workspace.reservation_capacity_in_gb_per_day == null || var.workspace.sku == "CapacityReservation"
    error_message = "workspace.reservation_capacity_in_gb_per_day can only be set when sku is CapacityReservation."
  }
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
    condition     = var.identity == null || !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) || length(var.identity.identity_ids) > 0
    error_message = "identity.identity_ids must be provided when identity.type includes UserAssigned."
  }
}

variable "features" {
  description = <<-EOT
    Workspace-linked resources managed by the module.

    Each list entry must have a unique name.
  EOT

  type = object({
    solutions = optional(list(object({
      name = string
      plan = object({
        publisher      = string
        product        = string
        promotion_code = optional(string)
      })
      tags = optional(map(string), {})
    })), [])

    data_export_rules = optional(list(object({
      name                    = string
      destination_resource_id = string
      table_names             = list(string)
      enabled                 = optional(bool, true)
    })), [])

    windows_event_datasources = optional(list(object({
      name           = string
      event_log_name = string
      event_types    = list(string)
    })), [])

    windows_performance_counters = optional(list(object({
      name             = string
      object_name      = string
      instance_name    = string
      counter_name     = string
      interval_seconds = number
    })), [])

    storage_insights = optional(list(object({
      name                 = string
      storage_account_id   = string
      storage_account_key  = string
      blob_container_names = optional(list(string))
      table_names          = optional(list(string))
    })), [])

    linked_services = optional(list(object({
      name            = string
      read_access_id  = string
      write_access_id = optional(string)
    })), [])

    clusters = optional(list(object({
      name                = string
      location            = optional(string)
      resource_group_name = optional(string)
      tags                = optional(map(string), {})
      identity = optional(object({
        type         = string
        identity_ids = optional(list(string), [])
      }))
    })), [])

    cluster_customer_managed_keys = optional(list(object({
      name                     = string
      log_analytics_cluster_id = optional(string)
      cluster_name             = optional(string)
      key_vault_key_id         = string
    })), [])
  })

  nullable = false
  default  = {}

  validation {
    condition     = length(distinct([for s in var.features.solutions : s.name])) == length(var.features.solutions)
    error_message = "features.solutions names must be unique."
  }

  validation {
    condition     = length(distinct([for r in var.features.data_export_rules : r.name])) == length(var.features.data_export_rules)
    error_message = "features.data_export_rules names must be unique."
  }

  validation {
    condition = alltrue([
      for r in var.features.data_export_rules : length(r.table_names) > 0
    ])
    error_message = "features.data_export_rules.table_names must contain at least one table."
  }

  validation {
    condition     = length(distinct([for ds in var.features.windows_event_datasources : ds.name])) == length(var.features.windows_event_datasources)
    error_message = "features.windows_event_datasources names must be unique."
  }

  validation {
    condition = alltrue([
      for ds in var.features.windows_event_datasources : ds.event_log_name != "" && length(ds.event_types) > 0
    ])
    error_message = "features.windows_event_datasources require event_log_name and at least one event_type."
  }

  validation {
    condition     = length(distinct([for ds in var.features.windows_performance_counters : ds.name])) == length(var.features.windows_performance_counters)
    error_message = "features.windows_performance_counters names must be unique."
  }

  validation {
    condition = alltrue([
      for ds in var.features.windows_performance_counters : ds.interval_seconds > 0
    ])
    error_message = "features.windows_performance_counters.interval_seconds must be greater than 0."
  }

  validation {
    condition     = length(distinct([for si in var.features.storage_insights : si.name])) == length(var.features.storage_insights)
    error_message = "features.storage_insights names must be unique."
  }

  validation {
    condition     = length(distinct([for ls in var.features.linked_services : ls.name])) == length(var.features.linked_services)
    error_message = "features.linked_services names must be unique."
  }

  validation {
    condition     = length(distinct([for c in var.features.clusters : c.name])) == length(var.features.clusters)
    error_message = "features.clusters names must be unique."
  }

  validation {
    condition = alltrue([
      for c in var.features.clusters :
      try(c.identity, null) == null || contains([
        "SystemAssigned",
        "UserAssigned",
        "SystemAssigned, UserAssigned"
      ], c.identity.type)
    ])
    error_message = "features.clusters.identity.type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }

  validation {
    condition = alltrue([
      for c in var.features.clusters :
      try(c.identity, null) == null || !contains(["UserAssigned", "SystemAssigned, UserAssigned"], c.identity.type) || length(try(c.identity.identity_ids, [])) > 0
    ])
    error_message = "features.clusters.identity.identity_ids must be provided when identity.type includes UserAssigned."
  }

  validation {
    condition     = length(distinct([for cmk in var.features.cluster_customer_managed_keys : cmk.name])) == length(var.features.cluster_customer_managed_keys)
    error_message = "features.cluster_customer_managed_keys names must be unique."
  }

  validation {
    condition = alltrue([
      for cmk in var.features.cluster_customer_managed_keys :
      (try(cmk.log_analytics_cluster_id, null) != null && try(cmk.log_analytics_cluster_id, "") != "") ||
      (try(cmk.cluster_name, null) != null && cmk.cluster_name != "")
    ])
    error_message = "features.cluster_customer_managed_keys require log_analytics_cluster_id or cluster_name."
  }

  validation {
    condition = alltrue([
      for cmk in var.features.cluster_customer_managed_keys :
      try(cmk.cluster_name, null) == null || contains([for c in var.features.clusters : c.name], cmk.cluster_name)
    ])
    error_message = "features.cluster_customer_managed_keys.cluster_name must reference a cluster defined in features.clusters."
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

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
