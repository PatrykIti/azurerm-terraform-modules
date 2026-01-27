variable "name" {
  description = "The name of the Data Collection Rule."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,64}$", var.name))
    error_message = "Data Collection Rule name must be 1-64 characters and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Data Collection Rule."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Data Collection Rule should exist."
  type        = string
}

variable "description" {
  description = "A description for the Data Collection Rule."
  type        = string
  default     = null
}

variable "kind" {
  description = "The kind of the Data Collection Rule. Possible values are Linux, Windows, AgentDirectToStore, and WorkspaceTransforms."
  type        = string
  default     = null

  validation {
    condition     = var.kind == null || contains(["Linux", "Windows", "AgentDirectToStore", "WorkspaceTransforms"], var.kind)
    error_message = "kind must be one of: Linux, Windows, AgentDirectToStore, WorkspaceTransforms."
  }
}

variable "data_collection_endpoint_id" {
  description = "The resource ID of the Data Collection Endpoint this rule can be used with."
  type        = string
  default     = null
}

variable "identity" {
  description = "Managed Service Identity configuration for the Data Collection Rule."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition     = var.identity == null || contains(["SystemAssigned", "UserAssigned"], var.identity.type)
    error_message = "identity.type must be SystemAssigned or UserAssigned."
  }
}

variable "destinations" {
  description = "Destination configuration for the Data Collection Rule."
  type = object({
    azure_monitor_metrics = optional(object({
      name = string
    }))
    event_hub = optional(list(object({
      name         = string
      event_hub_id = string
    })), [])
    event_hub_direct = optional(list(object({
      name         = string
      event_hub_id = string
    })), [])
    log_analytics = optional(list(object({
      name                  = string
      workspace_resource_id = string
    })), [])
    monitor_account = optional(list(object({
      name               = string
      monitor_account_id = string
    })), [])
    storage_blob = optional(list(object({
      name               = string
      storage_account_id = string
      container_name     = string
    })), [])
    storage_blob_direct = optional(list(object({
      name               = string
      storage_account_id = string
      container_name     = string
    })), [])
    storage_table_direct = optional(list(object({
      name               = string
      storage_account_id = string
      table_name         = string
    })), [])
  })

  nullable = false
  default  = {}

  validation {
    condition = length(distinct(concat(
      var.destinations.azure_monitor_metrics == null ? [] : [var.destinations.azure_monitor_metrics.name],
      [for d in try(var.destinations.event_hub, []) : d.name],
      [for d in try(var.destinations.event_hub_direct, []) : d.name],
      [for d in try(var.destinations.log_analytics, []) : d.name],
      [for d in try(var.destinations.monitor_account, []) : d.name],
      [for d in try(var.destinations.storage_blob, []) : d.name],
      [for d in try(var.destinations.storage_blob_direct, []) : d.name],
      [for d in try(var.destinations.storage_table_direct, []) : d.name]
      ))) == length(concat(
      var.destinations.azure_monitor_metrics == null ? [] : [var.destinations.azure_monitor_metrics.name],
      [for d in try(var.destinations.event_hub, []) : d.name],
      [for d in try(var.destinations.event_hub_direct, []) : d.name],
      [for d in try(var.destinations.log_analytics, []) : d.name],
      [for d in try(var.destinations.monitor_account, []) : d.name],
      [for d in try(var.destinations.storage_blob, []) : d.name],
      [for d in try(var.destinations.storage_blob_direct, []) : d.name],
      [for d in try(var.destinations.storage_table_direct, []) : d.name]
    ))
    error_message = "Destination names must be unique across all destination types."
  }

  validation {
    condition = length(concat(
      var.destinations.azure_monitor_metrics == null ? [] : [var.destinations.azure_monitor_metrics.name],
      [for d in try(var.destinations.event_hub, []) : d.name],
      [for d in try(var.destinations.event_hub_direct, []) : d.name],
      [for d in try(var.destinations.log_analytics, []) : d.name],
      [for d in try(var.destinations.monitor_account, []) : d.name],
      [for d in try(var.destinations.storage_blob, []) : d.name],
      [for d in try(var.destinations.storage_blob_direct, []) : d.name],
      [for d in try(var.destinations.storage_table_direct, []) : d.name]
    )) > 0
    error_message = "At least one destination must be configured."
  }
}

variable "data_flows" {
  description = "Data flow configuration for the Data Collection Rule."
  type = list(object({
    streams            = list(string)
    destinations       = list(string)
    built_in_transform = optional(string)
    output_stream      = optional(string)
    transform_kql      = optional(string)
  }))

  nullable = false
  default  = []

  validation {
    condition     = length(var.data_flows) > 0
    error_message = "At least one data_flow entry is required."
  }
}

variable "stream_declarations" {
  description = "Custom stream declarations for the Data Collection Rule."
  type = list(object({
    stream_name = string
    columns = list(object({
      name = string
      type = string
    }))
  }))
  default = []
}

variable "data_sources" {
  description = "Data sources configuration for the Data Collection Rule."
  type = object({
    data_import = optional(object({
      event_hub_data_source = object({
        name           = string
        stream         = string
        consumer_group = optional(string)
      })
    }))
    extension = optional(list(object({
      name               = string
      extension_name     = string
      streams            = list(string)
      input_data_sources = optional(list(string))
      extension_json     = optional(string)
    })), [])
    iis_log = optional(list(object({
      name            = string
      streams         = list(string)
      log_directories = list(string)
    })), [])
    log_file = optional(list(object({
      name          = string
      streams       = list(string)
      file_patterns = list(string)
      format        = string
      settings = optional(object({
        text = object({
          record_start_timestamp_format = string
        })
      }))
    })), [])
    performance_counter = optional(list(object({
      name                          = string
      streams                       = list(string)
      counter_specifiers            = list(string)
      sampling_frequency_in_seconds = number
    })), [])
    platform_telemetry = optional(list(object({
      name    = string
      streams = list(string)
    })), [])
    prometheus_forwarder = optional(list(object({
      name    = string
      streams = list(string)
      label_include_filter = optional(list(object({
        label = string
        value = string
      })), [])
    })), [])
    syslog = optional(list(object({
      name           = string
      facility_names = list(string)
      log_levels     = list(string)
      streams        = list(string)
    })), [])
    windows_event_log = optional(list(object({
      name           = string
      streams        = list(string)
      x_path_queries = list(string)
    })), [])
    windows_firewall_log = optional(list(object({
      name    = string
      streams = list(string)
    })), [])
  })
  default = null

  validation {
    condition = var.data_sources == null || length(distinct(concat(
      try([var.data_sources.data_import.event_hub_data_source.name], []),
      [for d in try(var.data_sources.extension, []) : d.name],
      [for d in try(var.data_sources.iis_log, []) : d.name],
      [for d in try(var.data_sources.log_file, []) : d.name],
      [for d in try(var.data_sources.performance_counter, []) : d.name],
      [for d in try(var.data_sources.platform_telemetry, []) : d.name],
      [for d in try(var.data_sources.prometheus_forwarder, []) : d.name],
      [for d in try(var.data_sources.syslog, []) : d.name],
      [for d in try(var.data_sources.windows_event_log, []) : d.name],
      [for d in try(var.data_sources.windows_firewall_log, []) : d.name]
      ))) == length(concat(
      try([var.data_sources.data_import.event_hub_data_source.name], []),
      [for d in try(var.data_sources.extension, []) : d.name],
      [for d in try(var.data_sources.iis_log, []) : d.name],
      [for d in try(var.data_sources.log_file, []) : d.name],
      [for d in try(var.data_sources.performance_counter, []) : d.name],
      [for d in try(var.data_sources.platform_telemetry, []) : d.name],
      [for d in try(var.data_sources.prometheus_forwarder, []) : d.name],
      [for d in try(var.data_sources.syslog, []) : d.name],
      [for d in try(var.data_sources.windows_event_log, []) : d.name],
      [for d in try(var.data_sources.windows_firewall_log, []) : d.name]
    ))
    error_message = "Data source names must be unique across all data source types."
  }

  validation {
    condition = var.kind == null || var.data_sources == null || !(
      var.kind == "Linux" && length(try(var.data_sources.windows_event_log, [])) > 0
    )
    error_message = "windows_event_log is not allowed when kind is Linux."
  }

  validation {
    condition = var.kind == null || var.data_sources == null || !(
      var.kind == "Windows" && length(try(var.data_sources.syslog, [])) > 0
    )
    error_message = "syslog is not allowed when kind is Windows."
  }
}

variable "monitoring" {
  description = <<-EOT
    Monitoring configuration for the Data Collection Rule.

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
    error_message = "Azure allows a maximum of 5 diagnostic settings per Data Collection Rule."
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
  description = "A mapping of tags to assign to the Data Collection Rule."
  type        = map(string)
  default     = {}
}
