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
# Variable Groups
# -----------------------------------------------------------------------------

variable "variable_groups" {
  description = "Map of variable groups to manage."
  type = map(object({
    name         = optional(string)
    description  = optional(string)
    allow_access = optional(bool)
    variables = list(object({
      name         = string
      value        = optional(string)
      secret_value = optional(string)
      is_secret    = optional(bool)
    }))
    key_vaults = optional(list(object({
      name                = string
      service_endpoint_id = string
      search_depth        = optional(number)
    })))
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for group in values(var.variable_groups) : (
        group.name == null || length(trimspace(group.name)) > 0
      )
    ])
    error_message = "variable_groups.name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for group in values(var.variable_groups) : length(group.variables) > 0
    ])
    error_message = "variable_groups.variables must contain at least one variable."
  }

  validation {
    condition = alltrue([
      for group in values(var.variable_groups) : alltrue([
        for variable in group.variables : length(trimspace(variable.name)) > 0
      ])
    ])
    error_message = "variable_groups.variables.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for group in values(var.variable_groups) : alltrue([
        for variable in group.variables : !(
          variable.value != null && variable.secret_value != null
        )
      ])
    ])
    error_message = "variable_groups.variables cannot set both value and secret_value."
  }

  validation {
    condition = alltrue([
      for group in values(var.variable_groups) : alltrue([
        for variable in group.variables : !(
          variable.is_secret == true && variable.secret_value == null
        )
      ])
    ])
    error_message = "variable_groups.variables.secret_value is required when is_secret is true."
  }

  validation {
    condition = alltrue([
      for group in values(var.variable_groups) : alltrue([
        for variable in group.variables : !(
          variable.secret_value != null && variable.is_secret != true
        )
      ])
    ])
    error_message = "variable_groups.variables.is_secret must be true when secret_value is set."
  }

  validation {
    condition = alltrue([
      for group in values(var.variable_groups) : alltrue([
        for vault in coalesce(group.key_vaults, []) : (
          length(trimspace(vault.name)) > 0 && length(trimspace(vault.service_endpoint_id)) > 0
        )
      ])
    ])
    error_message = "variable_groups.key_vaults require name and service_endpoint_id."
  }
}

# -----------------------------------------------------------------------------
# Variable Group Permissions
# -----------------------------------------------------------------------------

variable "variable_group_permissions" {
  description = "List of variable group permissions to assign."
  type = list(object({
    variable_group_id  = optional(string)
    variable_group_key = optional(string)
    principal          = string
    permissions        = map(string)
    replace            = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.variable_group_permissions : (
        (perm.variable_group_id != null) != (perm.variable_group_key != null)
      )
    ])
    error_message = "variable_group_permissions must set exactly one of variable_group_id or variable_group_key."
  }

  validation {
    condition = alltrue([
      for perm in var.variable_group_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "variable_group_permissions.principal must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Library Permissions
# -----------------------------------------------------------------------------

variable "library_permissions" {
  description = "List of library permissions to assign."
  type = list(object({
    principal   = string
    permissions = map(string)
    replace     = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.library_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "library_permissions.principal must be a non-empty string."
  }
}
