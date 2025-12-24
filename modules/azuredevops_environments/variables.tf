# -----------------------------------------------------------------------------
# Core
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Environments
# -----------------------------------------------------------------------------

variable "environments" {
  description = "Map of environments to manage."
  type = map(object({
    name        = optional(string)
    description = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for env in values(var.environments) : (
        env.name == null || length(trimspace(env.name)) > 0
      )
    ])
    error_message = "environments.name must be a non-empty string when provided."
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Resources
# -----------------------------------------------------------------------------

variable "kubernetes_resources" {
  description = "List of Kubernetes resources to attach to environments."
  type = list(object({
    environment_id   = optional(string)
    environment_key  = optional(string)
    service_endpoint_id = string
    name             = string
    namespace        = string
    cluster_name     = optional(string)
    tags             = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        (resource.environment_id != null) != (resource.environment_key != null)
      )
    ])
    error_message = "kubernetes_resources must set exactly one of environment_id or environment_key."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : length(trimspace(resource.name)) > 0
    ])
    error_message = "kubernetes_resources.name must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Approval Checks
# -----------------------------------------------------------------------------

variable "check_approvals" {
  description = "List of approval checks to configure."
  type = list(object({
    target_resource_id   = optional(string)
    target_environment_key = optional(string)
    target_resource_type = string
    approvers            = list(string)
    instructions         = optional(string)
    minimum_required_approvers = optional(number)
    requester_can_approve = optional(bool)
    timeout              = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_approvals : (
        check.target_resource_id != null || check.target_environment_key != null
      )
    ])
    error_message = "check_approvals must set target_resource_id or target_environment_key."
  }

  validation {
    condition = alltrue([
      for check in var.check_approvals : length(check.approvers) > 0
    ])
    error_message = "check_approvals.approvers must contain at least one entry."
  }
}

# -----------------------------------------------------------------------------
# Branch Control Checks
# -----------------------------------------------------------------------------

variable "check_branch_controls" {
  description = "List of branch control checks to configure."
  type = list(object({
    display_name         = string
    target_resource_id   = optional(string)
    target_environment_key = optional(string)
    target_resource_type = string
    allowed_branches     = optional(string)
    verify_branch_protection = optional(bool)
    ignore_unknown_protection_status = optional(bool)
    timeout              = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_branch_controls : length(trimspace(check.display_name)) > 0
    ])
    error_message = "check_branch_controls.display_name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for check in var.check_branch_controls : (
        check.target_resource_id != null || check.target_environment_key != null
      )
    ])
    error_message = "check_branch_controls must set target_resource_id or target_environment_key."
  }
}

# -----------------------------------------------------------------------------
# Business Hours Checks
# -----------------------------------------------------------------------------

variable "check_business_hours" {
  description = "List of business hours checks to configure."
  type = list(object({
    display_name         = string
    target_resource_id   = optional(string)
    target_environment_key = optional(string)
    target_resource_type = string
    start_time           = string
    end_time             = string
    time_zone            = string
    monday               = optional(bool)
    tuesday              = optional(bool)
    wednesday            = optional(bool)
    thursday             = optional(bool)
    friday               = optional(bool)
    saturday             = optional(bool)
    sunday               = optional(bool)
    timeout              = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_business_hours : length(trimspace(check.display_name)) > 0
    ])
    error_message = "check_business_hours.display_name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for check in var.check_business_hours : (
        check.target_resource_id != null || check.target_environment_key != null
      )
    ])
    error_message = "check_business_hours must set target_resource_id or target_environment_key."
  }
}

# -----------------------------------------------------------------------------
# Exclusive Lock Checks
# -----------------------------------------------------------------------------

variable "check_exclusive_locks" {
  description = "List of exclusive lock checks to configure."
  type = list(object({
    target_resource_id   = optional(string)
    target_environment_key = optional(string)
    target_resource_type = string
    timeout              = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_exclusive_locks : (
        check.target_resource_id != null || check.target_environment_key != null
      )
    ])
    error_message = "check_exclusive_locks must set target_resource_id or target_environment_key."
  }
}

# -----------------------------------------------------------------------------
# Required Template Checks
# -----------------------------------------------------------------------------

variable "check_required_templates" {
  description = "List of required template checks to configure."
  type = list(object({
    target_resource_id   = optional(string)
    target_environment_key = optional(string)
    target_resource_type = string
    required_templates   = list(object({
      template_path   = string
      repository_name = string
      repository_ref  = string
      repository_type = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_required_templates : (
        check.target_resource_id != null || check.target_environment_key != null
      )
    ])
    error_message = "check_required_templates must set target_resource_id or target_environment_key."
  }
}

# -----------------------------------------------------------------------------
# REST API Checks
# -----------------------------------------------------------------------------

variable "check_rest_apis" {
  description = "List of REST API checks to configure."
  type = list(object({
    display_name                  = string
    target_resource_id            = optional(string)
    target_environment_key        = optional(string)
    target_resource_type          = string
    connected_service_name_selector = string
    connected_service_name        = string
    method                        = string
    body                          = optional(string)
    headers                       = optional(string)
    retry_interval                = optional(number)
    success_criteria              = optional(string)
    url_suffix                    = optional(string)
    variable_group_name           = optional(string)
    completion_event              = optional(string)
    timeout                       = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_rest_apis : length(trimspace(check.display_name)) > 0
    ])
    error_message = "check_rest_apis.display_name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for check in var.check_rest_apis : (
        check.target_resource_id != null || check.target_environment_key != null
      )
    ])
    error_message = "check_rest_apis must set target_resource_id or target_environment_key."
  }
}
