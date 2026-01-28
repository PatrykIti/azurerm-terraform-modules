variable "name" {
  description = "The name of the Azure Monitor Private Link Scope."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name))
    error_message = "Monitor Private Link Scope name must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Azure Monitor Private Link Scope."
  type        = string
}

variable "ingestion_access_mode" {
  description = "Access mode for ingestion. Possible values are PrivateOnly and Open."
  type        = string
  default     = "PrivateOnly"

  validation {
    condition     = contains(["PrivateOnly", "Open"], var.ingestion_access_mode)
    error_message = "ingestion_access_mode must be one of: PrivateOnly, Open."
  }
}

variable "query_access_mode" {
  description = "Access mode for query. Possible values are PrivateOnly and Open."
  type        = string
  default     = "PrivateOnly"

  validation {
    condition     = contains(["PrivateOnly", "Open"], var.query_access_mode)
    error_message = "query_access_mode must be one of: PrivateOnly, Open."
  }
}

variable "scoped_services" {
  description = "Scoped services linked to the private link scope."
  type = list(object({
    name               = string
    linked_resource_id = string
  }))

  default = []

  validation {
    condition     = length(distinct([for s in var.scoped_services : s.name])) == length(var.scoped_services)
    error_message = "scoped_services names must be unique."
  }

  validation {
    condition = alltrue([
      for s in var.scoped_services : can(regex("^[A-Za-z0-9-]{1,63}$", s.name))
    ])
    error_message = "scoped_services.name must be 1-63 characters and contain only letters, numbers, and hyphens."
  }

  validation {
    condition = alltrue([
      for s in var.scoped_services : can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/[^/]+/.+", s.linked_resource_id))
    ])
    error_message = "scoped_services.linked_resource_id must be a valid Azure resource ID."
  }
}

variable "monitoring" {
  description = <<-EOT
    Monitoring configuration for the Azure Monitor Private Link Scope.

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
    error_message = "Azure allows a maximum of 5 diagnostic settings per resource."
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
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
