variable "name" {
  description = "The name of the Data Collection Endpoint."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,64}$", var.name))
    error_message = "Data Collection Endpoint name must be 1-64 characters and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Data Collection Endpoint."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Data Collection Endpoint should exist."
  type        = string
}

variable "kind" {
  description = "The kind of the Data Collection Endpoint. Possible values are Linux or Windows."
  type        = string
  default     = null

  validation {
    condition     = var.kind == null || contains(["Linux", "Windows"], var.kind)
    error_message = "kind must be either Linux or Windows when specified."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Data Collection Endpoint."
  type        = bool
  default     = null
}

variable "description" {
  description = "A description for the Data Collection Endpoint."
  type        = string
  default     = null
}

variable "monitoring" {
  description = <<-EOT
    Monitoring configuration for the Data Collection Endpoint.

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
    error_message = "Azure allows a maximum of 5 diagnostic settings per Data Collection Endpoint."
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
  description = "A mapping of tags to assign to the Data Collection Endpoint."
  type        = map(string)
  default     = {}
}
