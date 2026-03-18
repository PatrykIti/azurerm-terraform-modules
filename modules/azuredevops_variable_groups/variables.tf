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
  description = "Name of the Azure DevOps variable group."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "description" {
  description = "Description of the Azure DevOps variable group."
  type        = string
  default     = null

  validation {
    condition     = var.description == null || length(trimspace(var.description)) > 0
    error_message = "description must be a non-empty string when provided."
  }
}

variable "allow_access" {
  description = "Whether pipelines can access the variable group without explicit authorization."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "variables" {
  description = "List of variables to store in the variable group."
  type = list(object({
    name         = string
    value        = optional(string)
    secret_value = optional(string)
    is_secret    = optional(bool)
  }))
  sensitive = true

  validation {
    condition     = length(var.variables) > 0
    error_message = "variables must contain at least one variable."
  }

  validation {
    condition = alltrue([
      for variable in var.variables : length(trimspace(variable.name)) > 0
    ])
    error_message = "variables.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for variable in var.variables : (
        (variable.value != null) != (variable.secret_value != null)
      )
    ])
    error_message = "variables must set exactly one of value or secret_value."
  }

  validation {
    condition = alltrue([
      for variable in var.variables : !(
        variable.is_secret == true && variable.secret_value == null
      )
    ])
    error_message = "variables.secret_value is required when is_secret is true."
  }

  validation {
    condition = alltrue([
      for variable in var.variables : !(
        variable.secret_value != null && variable.is_secret == false
      )
    ])
    error_message = "variables.is_secret must be true when secret_value is set."
  }
}

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------

variable "key_vault" {
  description = "Optional Key Vault configuration for the variable group."
  type = object({
    name                = string
    service_endpoint_id = string
    search_depth        = optional(number)
  })
  default = null

  validation {
    condition = var.key_vault == null || (
      length(trimspace(var.key_vault.name)) > 0 &&
      length(trimspace(var.key_vault.service_endpoint_id)) > 0
    )
    error_message = "key_vault.name and key_vault.service_endpoint_id must be non-empty strings when provided."
  }

  validation {
    condition = var.key_vault == null || (
      var.key_vault.search_depth == null || var.key_vault.search_depth >= 0
    )
    error_message = "key_vault.search_depth must be 0 or greater when provided."
  }
}

# -----------------------------------------------------------------------------
# Variable Group Permissions (strict-child only)
# -----------------------------------------------------------------------------

variable "variable_group_permissions" {
  description = "List of variable group permissions to assign to the variable group created by this module."
  type = list(object({
    key         = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.variable_group_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "variable_group_permissions.principal must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for perm in var.variable_group_permissions : (
        perm.key == null || length(trimspace(perm.key)) > 0
      )
    ])
    error_message = "variable_group_permissions.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.variable_group_permissions : length(perm.permissions) > 0
    ])
    error_message = "variable_group_permissions.permissions must be a non-empty map."
  }

  validation {
    condition = alltrue([
      for perm in var.variable_group_permissions : alltrue([
        for status in values(perm.permissions) : contains(["allow", "deny", "notset"], lower(status))
      ])
    ])
    error_message = "variable_group_permissions.permissions values must be one of: Allow, Deny, NotSet."
  }

  validation {
    condition = length(distinct([
      for perm in var.variable_group_permissions : coalesce(perm.key, perm.principal)
    ])) == length(var.variable_group_permissions)
    error_message = "variable_group_permissions keys must be unique; set key when principal would collide."
  }
}
