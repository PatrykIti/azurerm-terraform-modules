variable "name" {
  description = "The name of the Application Insights component."
  type        = string

  validation {
    condition = (
      length(var.name) >= 1 &&
      length(var.name) <= 260 &&
      can(regex("^[A-Za-z0-9][A-Za-z0-9-._()]*$", var.name))
    )
    error_message = "Application Insights name must be 1-260 characters and contain only letters, numbers, dashes, dots, underscores, and parentheses."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create Application Insights."
  type        = string
}

variable "location" {
  description = "The Azure Region where Application Insights should exist."
  type        = string
}

variable "application_type" {
  description = "The type of Application Insights. Valid values are web or other."
  type        = string
  default     = "web"

  validation {
    condition     = contains(["web", "other"], var.application_type)
    error_message = "application_type must be one of: web, other."
  }
}

variable "workspace_id" {
  description = "The Log Analytics workspace ID for workspace-based Application Insights."
  type        = string
  default     = null
}

variable "retention_in_days" {
  description = "Retention period (in days) for Application Insights data."
  type        = number
  default     = null

  validation {
    condition     = var.retention_in_days == null || (var.retention_in_days >= 30 && var.retention_in_days <= 730)
    error_message = "retention_in_days must be between 30 and 730 when specified."
  }
}

variable "sampling_percentage" {
  description = "Sampling percentage for data ingestion (0-100)."
  type        = number
  default     = null

  validation {
    condition     = var.sampling_percentage == null || (var.sampling_percentage >= 0 && var.sampling_percentage <= 100)
    error_message = "sampling_percentage must be between 0 and 100 when specified."
  }
}

variable "daily_data_cap_in_gb" {
  description = "Daily data cap in GB for Application Insights."
  type        = number
  default     = null

  validation {
    condition     = var.daily_data_cap_in_gb == null || var.daily_data_cap_in_gb > 0
    error_message = "daily_data_cap_in_gb must be greater than 0 when specified."
  }
}

variable "daily_data_cap_notifications_disabled" {
  description = "Whether daily data cap notifications are disabled."
  type        = bool
  default     = false
}

variable "internet_ingestion_enabled" {
  description = "Whether ingestion over the public internet is enabled."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether query over the public internet is enabled."
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Whether local authentication is disabled."
  type        = bool
  default     = false
}

variable "disable_ip_masking" {
  description = "Whether IP masking is disabled."
  type        = bool
  default     = false
}

variable "api_keys" {
  description = "Application Insights API keys."
  type = list(object({
    name             = string
    read_permissions = optional(list(string), [])
    write_permissions = optional(list(string), [])
  }))

  default = []

  validation {
    condition     = length(distinct([for k in var.api_keys : k.name])) == length(var.api_keys)
    error_message = "api_keys names must be unique."
  }

  validation {
    condition = alltrue([
      for k in var.api_keys :
      length(try(k.read_permissions, [])) + length(try(k.write_permissions, [])) > 0
    ])
    error_message = "Each api_keys entry must have at least one read or write permission."
  }
}

variable "analytics_items" {
  description = "Analytics items for Application Insights."
  type = list(object({
    name    = string
    content = string
    scope   = string
    type    = string
  }))

  default = []

  validation {
    condition     = length(distinct([for item in var.analytics_items : item.name])) == length(var.analytics_items)
    error_message = "analytics_items names must be unique."
  }
}

variable "web_tests" {
  description = "Classic Application Insights web tests."
  type = list(object({
    name          = string
    kind          = optional(string, "ping")
    frequency     = optional(number, 300)
    timeout       = optional(number, 30)
    enabled       = optional(bool, true)
    geo_locations = list(string)
    web_test_xml  = string
    tags          = optional(map(string), {})
  }))

  default = []

  validation {
    condition     = length(distinct([for wt in var.web_tests : wt.name])) == length(var.web_tests)
    error_message = "web_tests names must be unique."
  }

  validation {
    condition = alltrue([
      for wt in var.web_tests :
      wt.frequency > 0 && wt.timeout > 0 && length(wt.geo_locations) > 0
    ])
    error_message = "web_tests require positive frequency/timeout and at least one geo location."
  }

  validation {
    condition = alltrue([
      for wt in var.web_tests : contains(["ping", "multistep"], wt.kind)
    ])
    error_message = "web_tests.kind must be one of: ping, multistep."
  }
}

variable "standard_web_tests" {
  description = "Standard Application Insights web tests."
  type = list(object({
    name          = string
    description   = optional(string)
    frequency     = optional(number, 300)
    timeout       = optional(number, 30)
    enabled       = optional(bool, true)
    geo_locations = list(string)
    request = object({
      url                              = string
      http_verb                        = optional(string, "GET")
      request_body                     = optional(string)
      follow_redirects_enabled         = optional(bool, true)
      parse_dependent_requests_enabled = optional(bool, true)
      headers                          = optional(map(string))
    })
    validation = optional(object({
      expected_status_code        = optional(number)
      ssl_check_enabled           = optional(bool)
      ssl_cert_remaining_lifetime = optional(number)
      content_match = optional(object({
        content            = string
        ignore_case        = optional(bool, true)
        pass_if_text_found = optional(bool, true)
      }))
    }))
    tags = optional(map(string), {})
  }))

  default = []

  validation {
    condition     = length(distinct([for wt in var.standard_web_tests : wt.name])) == length(var.standard_web_tests)
    error_message = "standard_web_tests names must be unique."
  }

  validation {
    condition = alltrue([
      for wt in var.standard_web_tests :
      wt.frequency > 0 && wt.timeout > 0 && length(wt.geo_locations) > 0
    ])
    error_message = "standard_web_tests require positive frequency/timeout and at least one geo location."
  }

  validation {
    condition = alltrue([
      for wt in var.standard_web_tests : wt.request.url != ""
    ])
    error_message = "standard_web_tests.request.url must be provided."
  }
}

variable "workbooks" {
  description = "Application Insights workbooks."
  type = list(object({
    name         = string
    display_name = string
    data_json    = string
    description  = optional(string)
    category     = optional(string)
    source_id    = optional(string)
    tags         = optional(map(string), {})
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }))
  }))

  default = []

  validation {
    condition     = length(distinct([for wb in var.workbooks : wb.name])) == length(var.workbooks)
    error_message = "workbooks names must be unique."
  }

  validation {
    condition = alltrue([
      for wb in var.workbooks :
      wb.identity == null || contains([
        "SystemAssigned",
        "UserAssigned",
        "SystemAssigned, UserAssigned"
      ], wb.identity.type)
    ])
    error_message = "workbooks.identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned when provided."
  }
}

variable "smart_detection_rules" {
  description = "Smart detection rules for Application Insights."
  type = list(object({
    name    = string
    enabled = optional(bool, true)
  }))

  default = []

  validation {
    condition     = length(distinct([for rule in var.smart_detection_rules : rule.name])) == length(var.smart_detection_rules)
    error_message = "smart_detection_rules names must be unique."
  }
}

variable "monitoring" {
  description = <<-EOT
    Monitoring configuration for Application Insights diagnostics.

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
    error_message = "Azure allows a maximum of 5 diagnostic settings per Application Insights resource."
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
  description = "Optional timeouts configuration for Application Insights."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
    read   = optional(string)
  })

  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
