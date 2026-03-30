# Core App Service Plan Variables
variable "name" {
  description = <<-EOT
    Name of the App Service Plan.
    Provide a non-empty plan name that is unique within the resource group.
  EOT
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "resource_group_name" {
  description = <<-EOT
    Name of the resource group where the App Service Plan is created.
    The resource group must already exist.
  EOT
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must be a non-empty string."
  }
}

variable "location" {
  description = <<-EOT
    Azure region where the App Service Plan is created.
    Typically match the resource group location.
  EOT
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must be a non-empty string."
  }
}

variable "service_plan" {
  description = <<-EOT
    Core App Service Plan configuration.

    os_type: Operating system type for workloads hosted by the plan.
    sku_name: App Service Plan SKU supported by azurerm 4.57.0.
    app_service_environment_id: Optional App Service Environment v3 ID for isolated plans.
    premium_plan_auto_scale_enabled: Enable autoscale support on Premium v2/v3/v4 plans.
    maximum_elastic_worker_count: Maximum number of elastic workers for Elastic Premium or Premium autoscale plans.
    worker_count: Number of workers allocated to the plan.
    per_site_scaling_enabled: Enable per-site scaling across apps hosted on the plan.
    zone_balancing_enabled: Balance workers across availability zones when supported.
    timeouts: Optional custom create/read/update/delete timeouts.
  EOT

  type = object({
    os_type                    = string
    sku_name                   = string
    app_service_environment_id = optional(string)

    premium_plan_auto_scale_enabled = optional(bool, false)
    maximum_elastic_worker_count    = optional(number)
    worker_count                    = optional(number)
    per_site_scaling_enabled        = optional(bool, false)
    zone_balancing_enabled          = optional(bool, false)

    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = contains(["Windows", "Linux", "WindowsContainer"], var.service_plan.os_type)
    error_message = "service_plan.os_type must be one of: Windows, Linux, WindowsContainer."
  }

  validation {
    condition = contains([
      "B1",
      "B2",
      "B3",
      "D1",
      "F1",
      "I1",
      "I2",
      "I3",
      "I1v2",
      "I1mv2",
      "I2v2",
      "I2mv2",
      "I3v2",
      "I3mv2",
      "I4v2",
      "I4mv2",
      "I5v2",
      "I5mv2",
      "I6v2",
      "P1v2",
      "P2v2",
      "P3v2",
      "P0v3",
      "P1v3",
      "P2v3",
      "P3v3",
      "P1mv3",
      "P2mv3",
      "P3mv3",
      "P4mv3",
      "P5mv3",
      "P0v4",
      "P1v4",
      "P2v4",
      "P3v4",
      "P1mv4",
      "P2mv4",
      "P3mv4",
      "P4mv4",
      "P5mv4",
      "S1",
      "S2",
      "S3",
      "SHARED",
      "EP1",
      "EP2",
      "EP3",
      "FC1",
      "WS1",
      "WS2",
      "WS3",
      "Y1",
    ], var.service_plan.sku_name)
    error_message = "service_plan.sku_name must be a valid App Service Plan SKU supported by azurerm 4.57.0."
  }

  validation {
    condition = var.service_plan.app_service_environment_id == null || (
      length(trimspace(var.service_plan.app_service_environment_id)) > 0
    )
    error_message = "service_plan.app_service_environment_id must be a non-empty string when set."
  }

  validation {
    condition = var.service_plan.maximum_elastic_worker_count == null || (
      var.service_plan.maximum_elastic_worker_count >= 1 &&
      var.service_plan.maximum_elastic_worker_count == floor(var.service_plan.maximum_elastic_worker_count)
    )
    error_message = "service_plan.maximum_elastic_worker_count must be a positive integer when set."
  }

  validation {
    condition = var.service_plan.worker_count == null || (
      var.service_plan.worker_count >= 1 &&
      var.service_plan.worker_count == floor(var.service_plan.worker_count)
    )
    error_message = "service_plan.worker_count must be a positive integer when set."
  }

  validation {
    condition = !var.service_plan.premium_plan_auto_scale_enabled || (
      startswith(var.service_plan.sku_name, "P")
    )
    error_message = "service_plan.premium_plan_auto_scale_enabled can only be enabled for Premium v2/v3/v4 SKUs."
  }

  validation {
    condition = var.service_plan.maximum_elastic_worker_count == null || (
      startswith(var.service_plan.sku_name, "EP") ||
      (startswith(var.service_plan.sku_name, "P") && var.service_plan.premium_plan_auto_scale_enabled)
    )
    error_message = "service_plan.maximum_elastic_worker_count requires an Elastic Premium SKU or a Premium SKU with premium_plan_auto_scale_enabled set to true."
  }

  validation {
    condition = !var.service_plan.zone_balancing_enabled || (
      contains(["Y1", "FC1"], var.service_plan.sku_name) ||
      startswith(var.service_plan.sku_name, "P") ||
      startswith(var.service_plan.sku_name, "EP") ||
      startswith(var.service_plan.sku_name, "I") ||
      startswith(var.service_plan.sku_name, "WS")
    )
    error_message = "service_plan.zone_balancing_enabled is supported only for Consumption, Premium, Elastic Premium, Isolated, or Workflow SKUs."
  }

  validation {
    condition = !var.service_plan.zone_balancing_enabled || (
      var.service_plan.worker_count != null &&
      var.service_plan.worker_count > 1
    )
    error_message = "service_plan.zone_balancing_enabled requires service_plan.worker_count to be greater than 1."
  }

  validation {
    condition = var.service_plan.app_service_environment_id == null || contains([
      "I1v2",
      "I1mv2",
      "I2v2",
      "I2mv2",
      "I3v2",
      "I3mv2",
      "I4v2",
      "I4mv2",
      "I5v2",
      "I5mv2",
      "I6v2",
    ], var.service_plan.sku_name)
    error_message = "service_plan.app_service_environment_id requires an Isolated v2 SKU supported by App Service Environment v3."
  }
}

variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for the App Service Plan.

    Supported categories for Microsoft.Web/serverfarms used by this module:
    - log_categories: AppServiceConsoleLogs
    - metric_categories: AllMetrics

    Entries with no log or metric categories are skipped and reported in
    diagnostic_settings_skipped.
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
    partner_solution_id            = optional(string)
  }))

  nullable = false
  default  = []

  validation {
    condition     = length(var.diagnostic_settings) <= 5
    error_message = "Azure allows a maximum of 5 diagnostic settings per App Service Plan."
  }

  validation {
    condition     = length(distinct([for diagnostic_setting in var.diagnostic_settings : diagnostic_setting.name])) == length(var.diagnostic_settings)
    error_message = "Each diagnostic_settings entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for diagnostic_setting in var.diagnostic_settings :
      length(trimspace(diagnostic_setting.name)) > 0
    ])
    error_message = "diagnostic_settings.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for diagnostic_setting in var.diagnostic_settings :
      diagnostic_setting.log_analytics_workspace_id != null ||
      diagnostic_setting.storage_account_id != null ||
      diagnostic_setting.eventhub_authorization_rule_id != null ||
      diagnostic_setting.partner_solution_id != null
    ])
    error_message = "Each diagnostic_settings entry must specify at least one destination."
  }

  validation {
    condition = alltrue([
      for diagnostic_setting in var.diagnostic_settings :
      diagnostic_setting.eventhub_authorization_rule_id == null || (
        diagnostic_setting.eventhub_name != null &&
        trimspace(diagnostic_setting.eventhub_name) != ""
      )
    ])
    error_message = "diagnostic_settings.eventhub_name is required when eventhub_authorization_rule_id is set."
  }

  validation {
    condition = alltrue([
      for diagnostic_setting in var.diagnostic_settings :
      diagnostic_setting.log_analytics_destination_type == null || contains([
        "Dedicated",
        "AzureDiagnostics",
      ], diagnostic_setting.log_analytics_destination_type)
    ])
    error_message = "diagnostic_settings.log_analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }

  validation {
    condition = alltrue(flatten([
      for diagnostic_setting in var.diagnostic_settings : [
        for category in(diagnostic_setting.log_categories == null ? [] : diagnostic_setting.log_categories) :
        contains(["AppServiceConsoleLogs"], trimspace(category))
      ]
    ]))
    error_message = "diagnostic_settings.log_categories must use supported values: AppServiceConsoleLogs."
  }

  validation {
    condition = alltrue(flatten([
      for diagnostic_setting in var.diagnostic_settings : [
        for category in(diagnostic_setting.metric_categories == null ? [] : diagnostic_setting.metric_categories) :
        contains(["AllMetrics"], trimspace(category))
      ]
    ]))
    error_message = "diagnostic_settings.metric_categories must use supported values: AllMetrics."
  }
}

variable "tags" {
  description = <<-EOT
    Tags to apply to the App Service Plan.
    Provide a map of string keys and values.
  EOT
  type        = map(string)
  default     = {}
}
