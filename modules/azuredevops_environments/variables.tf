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
  description = "List of Kubernetes resources to attach to the environment. Checks can be nested per resource."
  type = list(object({
    name                = string
    service_endpoint_id = string
    namespace           = string
    cluster_name        = optional(string)
    tags                = optional(list(string))
    checks = optional(object({
      approvals = optional(list(object({
        name                       = string
        approvers                  = list(string)
        instructions               = optional(string)
        minimum_required_approvers = optional(number)
        requester_can_approve      = optional(bool)
        timeout                    = optional(number)
      })), [])
      branch_controls = optional(list(object({
        name                             = string
        allowed_branches                 = optional(string)
        verify_branch_protection         = optional(bool)
        ignore_unknown_protection_status = optional(bool)
        timeout                          = optional(number)
      })), [])
      business_hours = optional(list(object({
        name       = string
        start_time = string
        end_time   = string
        time_zone  = string
        monday     = optional(bool)
        tuesday    = optional(bool)
        wednesday  = optional(bool)
        thursday   = optional(bool)
        friday     = optional(bool)
        saturday   = optional(bool)
        sunday     = optional(bool)
        timeout    = optional(number)
      })), [])
      exclusive_locks = optional(list(object({
        name    = string
        timeout = optional(number)
      })), [])
      required_templates = optional(list(object({
        name = string
        required_templates = list(object({
          template_path   = string
          repository_name = string
          repository_ref  = string
          repository_type = optional(string)
        }))
      })), [])
      rest_apis = optional(list(object({
        name                            = string
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
      })), [])
    }), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : length(trimspace(resource.name)) > 0
    ])
    error_message = "kubernetes_resources.name must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for resource in var.kubernetes_resources : resource.name
    ])) == length(var.kubernetes_resources)
    error_message = "kubernetes_resources.name values must be unique."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : length(trimspace(resource.service_endpoint_id)) > 0
    ])
    error_message = "kubernetes_resources.service_endpoint_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : length(trimspace(resource.namespace)) > 0
    ])
    error_message = "kubernetes_resources.namespace must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        resource.cluster_name == null || length(trimspace(resource.cluster_name)) > 0
      )
    ])
    error_message = "kubernetes_resources.cluster_name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        resource.tags == null ? true : alltrue([
          for tag in resource.tags : length(trimspace(tag)) > 0
        ])
      )
    ])
    error_message = "kubernetes_resources.tags must contain non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.approvals, []) : length(trimspace(check.name)) > 0
      ])
    ])
    error_message = "kubernetes_resources.checks.approvals.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        length(distinct([
          for check in try(resource.checks.approvals, []) : check.name
        ])) == length(try(resource.checks.approvals, []))
      )
    ])
    error_message = "kubernetes_resources.checks.approvals names must be unique per resource."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.approvals, []) : length(check.approvers) > 0
      ])
    ])
    error_message = "kubernetes_resources.checks.approvals.approvers must contain at least one entry."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.approvals, []) : alltrue([
          for approver in check.approvers : length(trimspace(approver)) > 0
        ])
      ])
    ])
    error_message = "kubernetes_resources.checks.approvals.approvers entries must be non-empty strings."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.approvals, []) : (
          check.minimum_required_approvers == null || (
            check.minimum_required_approvers >= 1 &&
            check.minimum_required_approvers <= length(check.approvers)
          )
        )
      ])
    ])
    error_message = "kubernetes_resources.checks.approvals.minimum_required_approvers must be between 1 and the number of approvers."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.branch_controls, []) : length(trimspace(check.name)) > 0
      ])
    ])
    error_message = "kubernetes_resources.checks.branch_controls.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        length(distinct([
          for check in try(resource.checks.branch_controls, []) : check.name
        ])) == length(try(resource.checks.branch_controls, []))
      )
    ])
    error_message = "kubernetes_resources.checks.branch_controls names must be unique per resource."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.branch_controls, []) : (
          check.allowed_branches == null || length(trimspace(check.allowed_branches)) > 0
        )
      ])
    ])
    error_message = "kubernetes_resources.checks.branch_controls.allowed_branches must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.business_hours, []) : length(trimspace(check.name)) > 0
      ])
    ])
    error_message = "kubernetes_resources.checks.business_hours.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        length(distinct([
          for check in try(resource.checks.business_hours, []) : check.name
        ])) == length(try(resource.checks.business_hours, []))
      )
    ])
    error_message = "kubernetes_resources.checks.business_hours names must be unique per resource."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.business_hours, []) : (
          length(trimspace(check.start_time)) > 0 &&
          length(trimspace(check.end_time)) > 0 &&
          length(trimspace(check.time_zone)) > 0
        )
      ])
    ])
    error_message = "kubernetes_resources.checks.business_hours.start_time, end_time, and time_zone must be non-empty strings."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.exclusive_locks, []) : length(trimspace(check.name)) > 0
      ])
    ])
    error_message = "kubernetes_resources.checks.exclusive_locks.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        length(distinct([
          for check in try(resource.checks.exclusive_locks, []) : check.name
        ])) == length(try(resource.checks.exclusive_locks, []))
      )
    ])
    error_message = "kubernetes_resources.checks.exclusive_locks names must be unique per resource."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.required_templates, []) : length(trimspace(check.name)) > 0
      ])
    ])
    error_message = "kubernetes_resources.checks.required_templates.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        length(distinct([
          for check in try(resource.checks.required_templates, []) : check.name
        ])) == length(try(resource.checks.required_templates, []))
      )
    ])
    error_message = "kubernetes_resources.checks.required_templates names must be unique per resource."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.required_templates, []) : length(check.required_templates) > 0
      ])
    ])
    error_message = "kubernetes_resources.checks.required_templates.required_templates must contain at least one entry."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.required_templates, []) : alltrue([
          for template in check.required_templates : (
            length(trimspace(template.template_path)) > 0 &&
            length(trimspace(template.repository_name)) > 0 &&
            length(trimspace(template.repository_ref)) > 0 &&
            (template.repository_type == null || length(trimspace(template.repository_type)) > 0)
          )
        ])
      ])
    ])
    error_message = "kubernetes_resources.checks.required_templates.required_templates must include non-empty template_path, repository_name, and repository_ref."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.rest_apis, []) : length(trimspace(check.name)) > 0
      ])
    ])
    error_message = "kubernetes_resources.checks.rest_apis.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : (
        length(distinct([
          for check in try(resource.checks.rest_apis, []) : check.name
        ])) == length(try(resource.checks.rest_apis, []))
      )
    ])
    error_message = "kubernetes_resources.checks.rest_apis names must be unique per resource."
  }

  validation {
    condition = alltrue([
      for resource in var.kubernetes_resources : alltrue([
        for check in try(resource.checks.rest_apis, []) : (
          length(trimspace(check.connected_service_name_selector)) > 0 &&
          length(trimspace(check.connected_service_name)) > 0 &&
          length(trimspace(check.method)) > 0
        )
      ])
    ])
    error_message = "kubernetes_resources.checks.rest_apis.connected_service_name_selector, connected_service_name, and method must be non-empty strings."
  }
}

# -----------------------------------------------------------------------------
# Environment Checks
# -----------------------------------------------------------------------------

variable "check_approvals" {
  description = "List of approval checks to configure for the environment."
  type = list(object({
    name                       = string
    approvers                  = list(string)
    instructions               = optional(string)
    minimum_required_approvers = optional(number)
    requester_can_approve      = optional(bool)
    timeout                    = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_approvals : length(trimspace(check.name)) > 0
    ])
    error_message = "check_approvals.name must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for check in var.check_approvals : check.name
    ])) == length(var.check_approvals)
    error_message = "check_approvals names must be unique."
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
        check.minimum_required_approvers == null || (
          check.minimum_required_approvers >= 1 &&
          check.minimum_required_approvers <= length(check.approvers)
        )
      )
    ])
    error_message = "check_approvals.minimum_required_approvers must be between 1 and the number of approvers."
  }
}

variable "check_branch_controls" {
  description = "List of branch control checks to configure for the environment."
  type = list(object({
    name                             = string
    allowed_branches                 = optional(string)
    verify_branch_protection         = optional(bool)
    ignore_unknown_protection_status = optional(bool)
    timeout                          = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_branch_controls : length(trimspace(check.name)) > 0
    ])
    error_message = "check_branch_controls.name must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for check in var.check_branch_controls : check.name
    ])) == length(var.check_branch_controls)
    error_message = "check_branch_controls names must be unique."
  }

  validation {
    condition = alltrue([
      for check in var.check_branch_controls : (
        check.allowed_branches == null || length(trimspace(check.allowed_branches)) > 0
      )
    ])
    error_message = "check_branch_controls.allowed_branches must be a non-empty string when provided."
  }
}

variable "check_business_hours" {
  description = "List of business hours checks to configure for the environment."
  type = list(object({
    name       = string
    start_time = string
    end_time   = string
    time_zone  = string
    monday     = optional(bool)
    tuesday    = optional(bool)
    wednesday  = optional(bool)
    thursday   = optional(bool)
    friday     = optional(bool)
    saturday   = optional(bool)
    sunday     = optional(bool)
    timeout    = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_business_hours : length(trimspace(check.name)) > 0
    ])
    error_message = "check_business_hours.name must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for check in var.check_business_hours : check.name
    ])) == length(var.check_business_hours)
    error_message = "check_business_hours names must be unique."
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
}

variable "check_exclusive_locks" {
  description = "List of exclusive lock checks to configure for the environment."
  type = list(object({
    name    = string
    timeout = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for check in var.check_exclusive_locks : length(trimspace(check.name)) > 0
    ])
    error_message = "check_exclusive_locks.name must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for check in var.check_exclusive_locks : check.name
    ])) == length(var.check_exclusive_locks)
    error_message = "check_exclusive_locks names must be unique."
  }
}

variable "check_required_templates" {
  description = "List of required template checks to configure for the environment."
  type = list(object({
    name = string
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
      for check in var.check_required_templates : length(trimspace(check.name)) > 0
    ])
    error_message = "check_required_templates.name must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for check in var.check_required_templates : check.name
    ])) == length(var.check_required_templates)
    error_message = "check_required_templates names must be unique."
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
}

variable "check_rest_apis" {
  description = "List of REST API checks to configure for the environment."
  type = list(object({
    name                            = string
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
      for check in var.check_rest_apis : length(trimspace(check.name)) > 0
    ])
    error_message = "check_rest_apis.name must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for check in var.check_rest_apis : check.name
    ])) == length(var.check_rest_apis)
    error_message = "check_rest_apis names must be unique."
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
}
