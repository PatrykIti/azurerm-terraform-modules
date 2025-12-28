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

variable "name" {
  description = "Name of the Azure DevOps environment."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "description" {
  description = "Optional description for the Azure DevOps environment."
  type        = string
  default     = null

  validation {
    condition     = var.description == null || length(trimspace(var.description)) > 0
    error_message = "description must be a non-empty string when provided."
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Resources
# -----------------------------------------------------------------------------

variable "kubernetes_resources" {
  description = "List of Kubernetes resources to attach to the environment."
  type = list(object({
    key                 = optional(string)
    environment_id      = optional(string)
    service_endpoint_id = string
    name                = string
    namespace           = string
    cluster_name        = optional(string)
    tags                = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        resource.key == null || length(trimspace(resource.key)) > 0
      )
    ])
    error_message = "kubernetes_resources.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        resource.environment_id == null || length(trimspace(resource.environment_id)) > 0
      )
    ])
    error_message = "kubernetes_resources.environment_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : length(trimspace(resource.service_endpoint_id)) > 0
    ])
    error_message = "kubernetes_resources.service_endpoint_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : length(trimspace(resource.name)) > 0
    ])
    error_message = "kubernetes_resources.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : length(trimspace(resource.namespace)) > 0
    ])
    error_message = "kubernetes_resources.namespace must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for resource in var.kubernetes_resources :
      (
        resource.key != null && length(trimspace(resource.key)) > 0
        ? resource.key
        : resource.name
      )
    ])) == length(var.kubernetes_resources)
    error_message = "kubernetes_resources keys must be unique; set key when names would collide."
  }
}

# -----------------------------------------------------------------------------
# Approval Checks
# -----------------------------------------------------------------------------

variable "check_approvals" {
  description = "List of approval checks to configure."
  type = list(object({
    key                        = optional(string)
    target_resource_id         = optional(string)
    target_resource_type       = optional(string)
    approvers                  = list(string)
    instructions               = optional(string)
    minimum_required_approvers = optional(number)
    requester_can_approve      = optional(bool)
    timeout                    = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_approvals : (
        check.key == null || length(trimspace(check.key)) > 0
      )
    ])
    error_message = "check_approvals.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_approvals : (
        check.target_resource_id == null || length(trimspace(check.target_resource_id)) > 0
      )
    ])
    error_message = "check_approvals.target_resource_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_approvals :
      check.target_resource_type == null || contains(["environment", "environmentResource"], check.target_resource_type)
    ])
    error_message = "check_approvals.target_resource_type must be one of: environment, environmentResource."
  }

  validation {
    condition = alltrue([
      for check in var.check_approvals : (
        check.key != null || check.target_resource_id != null
      )
    ])
    error_message = "check_approvals must set key or target_resource_id."
  }

  validation {
    condition = alltrue([
      for check in var.check_approvals : length(check.approvers) > 0
    ])
    error_message = "check_approvals.approvers must contain at least one entry."
  }

  validation {
    condition = alltrue([
      for check in var.check_approvals : alltrue([
        for approver in check.approvers : length(trimspace(approver)) > 0
      ])
    ])
    error_message = "check_approvals.approvers entries must be non-empty strings."
  }

  validation {
    condition = alltrue([
      for check in var.check_approvals : (
        check.minimum_required_approvers == null ||
        (check.minimum_required_approvers >= 1 && check.minimum_required_approvers <= length(check.approvers))
      )
    ])
    error_message = "check_approvals.minimum_required_approvers must be between 1 and the number of approvers."
  }

  validation {
    condition = length(distinct([
      for check in var.check_approvals :
      coalesce(check.key, check.target_resource_id)
    ])) == length(var.check_approvals)
    error_message = "check_approvals keys must be unique; set key when target_resource_id would collide."
  }
}

# -----------------------------------------------------------------------------
# Branch Control Checks
# -----------------------------------------------------------------------------

variable "check_branch_controls" {
  description = "List of branch control checks to configure."
  type = list(object({
    key                              = optional(string)
    display_name                     = string
    target_resource_id               = optional(string)
    target_resource_type             = optional(string)
    allowed_branches                 = optional(string)
    verify_branch_protection         = optional(bool)
    ignore_unknown_protection_status = optional(bool)
    timeout                          = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_branch_controls : (
        check.key == null || length(trimspace(check.key)) > 0
      )
    ])
    error_message = "check_branch_controls.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_branch_controls : length(trimspace(check.display_name)) > 0
    ])
    error_message = "check_branch_controls.display_name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for check in var.check_branch_controls : (
        check.target_resource_id == null || length(trimspace(check.target_resource_id)) > 0
      )
    ])
    error_message = "check_branch_controls.target_resource_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_branch_controls :
      check.target_resource_type == null || contains(["environment", "environmentResource"], check.target_resource_type)
    ])
    error_message = "check_branch_controls.target_resource_type must be one of: environment, environmentResource."
  }

  validation {
    condition = length(distinct([
      for check in var.check_branch_controls :
      coalesce(check.key, check.display_name, check.target_resource_id)
    ])) == length(var.check_branch_controls)
    error_message = "check_branch_controls keys must be unique; set key when display_name would collide."
  }
}

# -----------------------------------------------------------------------------
# Business Hours Checks
# -----------------------------------------------------------------------------

variable "check_business_hours" {
  description = "List of business hours checks to configure."
  type = list(object({
    key                  = optional(string)
    display_name         = string
    target_resource_id   = optional(string)
    target_resource_type = optional(string)
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
      for check in var.check_business_hours : (
        check.key == null || length(trimspace(check.key)) > 0
      )
    ])
    error_message = "check_business_hours.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_business_hours : length(trimspace(check.display_name)) > 0
    ])
    error_message = "check_business_hours.display_name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for check in var.check_business_hours : (
        length(trimspace(check.start_time)) > 0 &&
        length(trimspace(check.end_time)) > 0 &&
        length(trimspace(check.time_zone)) > 0
      )
    ])
    error_message = "check_business_hours.start_time, end_time, and time_zone must be non-empty strings."
  }

  validation {
    condition = alltrue([
      for check in var.check_business_hours : (
        check.target_resource_id == null || length(trimspace(check.target_resource_id)) > 0
      )
    ])
    error_message = "check_business_hours.target_resource_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_business_hours :
      check.target_resource_type == null || contains(["environment", "environmentResource"], check.target_resource_type)
    ])
    error_message = "check_business_hours.target_resource_type must be one of: environment, environmentResource."
  }

  validation {
    condition = length(distinct([
      for check in var.check_business_hours :
      coalesce(check.key, check.display_name, check.target_resource_id)
    ])) == length(var.check_business_hours)
    error_message = "check_business_hours keys must be unique; set key when display_name would collide."
  }
}

# -----------------------------------------------------------------------------
# Exclusive Lock Checks
# -----------------------------------------------------------------------------

variable "check_exclusive_locks" {
  description = "List of exclusive lock checks to configure."
  type = list(object({
    key                  = optional(string)
    target_resource_id   = optional(string)
    target_resource_type = optional(string)
    timeout              = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_exclusive_locks : (
        check.key == null || length(trimspace(check.key)) > 0
      )
    ])
    error_message = "check_exclusive_locks.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_exclusive_locks : (
        check.target_resource_id == null || length(trimspace(check.target_resource_id)) > 0
      )
    ])
    error_message = "check_exclusive_locks.target_resource_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_exclusive_locks :
      check.target_resource_type == null || contains(["environment", "environmentResource"], check.target_resource_type)
    ])
    error_message = "check_exclusive_locks.target_resource_type must be one of: environment, environmentResource."
  }

  validation {
    condition = alltrue([
      for check in var.check_exclusive_locks : (
        check.key != null || check.target_resource_id != null
      )
    ])
    error_message = "check_exclusive_locks must set key or target_resource_id."
  }

  validation {
    condition = length(distinct([
      for check in var.check_exclusive_locks :
      coalesce(check.key, check.target_resource_id)
    ])) == length(var.check_exclusive_locks)
    error_message = "check_exclusive_locks keys must be unique; set key when target_resource_id would collide."
  }
}

# -----------------------------------------------------------------------------
# Required Template Checks
# -----------------------------------------------------------------------------

variable "check_required_templates" {
  description = "List of required template checks to configure."
  type = list(object({
    key                  = optional(string)
    target_resource_id   = optional(string)
    target_resource_type = optional(string)
    required_templates = list(object({
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
        check.key == null || length(trimspace(check.key)) > 0
      )
    ])
    error_message = "check_required_templates.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_required_templates : (
        check.target_resource_id == null || length(trimspace(check.target_resource_id)) > 0
      )
    ])
    error_message = "check_required_templates.target_resource_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_required_templates :
      check.target_resource_type == null || contains(["environment", "environmentResource"], check.target_resource_type)
    ])
    error_message = "check_required_templates.target_resource_type must be one of: environment, environmentResource."
  }

  validation {
    condition = alltrue([
      for check in var.check_required_templates : (
        check.key != null || check.target_resource_id != null
      )
    ])
    error_message = "check_required_templates must set key or target_resource_id."
  }

  validation {
    condition = alltrue([
      for check in var.check_required_templates : length(check.required_templates) > 0
    ])
    error_message = "check_required_templates.required_templates must contain at least one entry."
  }

  validation {
    condition = alltrue([
      for check in var.check_required_templates : alltrue([
        for template in check.required_templates : (
          length(trimspace(template.template_path)) > 0 &&
          length(trimspace(template.repository_name)) > 0 &&
          length(trimspace(template.repository_ref)) > 0 &&
          (template.repository_type == null || length(trimspace(template.repository_type)) > 0)
        )
      ])
    ])
    error_message = "check_required_templates.required_templates must include non-empty template_path, repository_name, and repository_ref."
  }

  validation {
    condition = length(distinct([
      for check in var.check_required_templates :
      coalesce(check.key, check.target_resource_id)
    ])) == length(var.check_required_templates)
    error_message = "check_required_templates keys must be unique; set key when target_resource_id would collide."
  }
}

# -----------------------------------------------------------------------------
# REST API Checks
# -----------------------------------------------------------------------------

variable "check_rest_apis" {
  description = "List of REST API checks to configure."
  type = list(object({
    key                             = optional(string)
    display_name                    = string
    target_resource_id              = optional(string)
    target_resource_type            = optional(string)
    connected_service_name_selector = string
    connected_service_name          = string
    method                          = string
    body                            = optional(string)
    headers                         = optional(string)
    retry_interval                  = optional(number)
    success_criteria                = optional(string)
    url_suffix                      = optional(string)
    variable_group_name             = optional(string)
    completion_event                = optional(string)
    timeout                         = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_rest_apis : (
        check.key == null || length(trimspace(check.key)) > 0
      )
    ])
    error_message = "check_rest_apis.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_rest_apis : length(trimspace(check.display_name)) > 0
    ])
    error_message = "check_rest_apis.display_name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for check in var.check_rest_apis : (
        length(trimspace(check.connected_service_name_selector)) > 0 &&
        length(trimspace(check.connected_service_name)) > 0 &&
        length(trimspace(check.method)) > 0
      )
    ])
    error_message = "check_rest_apis.connected_service_name_selector, connected_service_name, and method must be non-empty strings."
  }

  validation {
    condition = alltrue([
      for check in var.check_rest_apis : (
        check.target_resource_id == null || length(trimspace(check.target_resource_id)) > 0
      )
    ])
    error_message = "check_rest_apis.target_resource_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for check in var.check_rest_apis :
      check.target_resource_type == null || contains(["environment", "environmentResource"], check.target_resource_type)
    ])
    error_message = "check_rest_apis.target_resource_type must be one of: environment, environmentResource."
  }

  validation {
    condition = length(distinct([
      for check in var.check_rest_apis :
      coalesce(check.key, check.display_name, check.target_resource_id)
    ])) == length(var.check_rest_apis)
    error_message = "check_rest_apis keys must be unique; set key when display_name would collide."
  }
}
