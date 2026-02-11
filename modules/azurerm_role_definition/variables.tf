# Core Role Definition Variables
variable "name" {
  description = "The display name of the role definition."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "role_definition_id" {
  description = "Optional role definition ID (GUID). When omitted, Azure will generate one."
  type        = string
  default     = null

  validation {
    condition     = var.role_definition_id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.role_definition_id))
    error_message = "role_definition_id must be a valid GUID when provided."
  }
}

variable "scope" {
  description = "The scope at which the role definition is created (management group, subscription, or resource group)."
  type        = string

  validation {
    condition     = length(trimspace(var.scope)) > 0
    error_message = "scope must be a non-empty string."
  }

  validation {
    condition = can(regex(
      "^/subscriptions/[^/]+(/.*)?$|^/providers/Microsoft\\.Management/managementGroups/[^/]+(/.*)?$",
      var.scope
    ))
    error_message = "scope must be a valid ARM ID for management group, subscription, or resource group scope."
  }
}

variable "description" {
  description = "Optional description of the role definition."
  type        = string
  default     = null
}

variable "permissions" {
  description = "List of permission blocks defining actions and data actions for the role."
  type = list(object({
    actions          = optional(list(string), [])
    not_actions      = optional(list(string), [])
    data_actions     = optional(list(string), [])
    not_data_actions = optional(list(string), [])
  }))

  validation {
    condition     = length(var.permissions) > 0
    error_message = "permissions must contain at least one item."
  }

  validation {
    condition = alltrue([
      for permission in var.permissions :
      length(try(permission.actions, [])) > 0 || length(try(permission.data_actions, [])) > 0
    ])
    error_message = "Each role definition must include at least one action or data_action."
  }

  validation {
    condition = alltrue([
      for permission in var.permissions :
      alltrue([for action in try(permission.actions, []) : length(trimspace(action)) > 0]) &&
      alltrue([for action in try(permission.not_actions, []) : length(trimspace(action)) > 0]) &&
      alltrue([for action in try(permission.data_actions, []) : length(trimspace(action)) > 0]) &&
      alltrue([for action in try(permission.not_data_actions, []) : length(trimspace(action)) > 0])
    ])
    error_message = "permissions actions and data actions must not contain empty strings."
  }
}

variable "assignable_scopes" {
  description = "List of scopes at which the role definition is assignable."
  type        = list(string)

  validation {
    condition     = length(var.assignable_scopes) > 0
    error_message = "assignable_scopes must contain at least one scope."
  }

  validation {
    condition     = alltrue([for scope in var.assignable_scopes : length(trimspace(scope)) > 0])
    error_message = "assignable_scopes must not contain empty strings."
  }

  validation {
    condition = alltrue([
      for assignable_scope in var.assignable_scopes :
      trimspace(assignable_scope) == trimspace(var.scope) || startswith(trimspace(assignable_scope), "${trimspace(var.scope)}/")
    ])
    error_message = "assignable_scopes must be the same as scope or child scopes of scope."
  }

  validation {
    condition = !(
      (
        can(regex("^/providers/Microsoft\\.Management/managementGroups/", trimspace(var.scope))) ||
        anytrue([
          for assignable_scope in var.assignable_scopes :
          can(regex("^/providers/Microsoft\\.Management/managementGroups/", trimspace(assignable_scope)))
        ])
      ) &&
      anytrue([for permission in var.permissions : length(try(permission.data_actions, [])) > 0])
    )
    error_message = "data_actions are not supported when assignable_scopes include a management group scope."
  }
}

variable "timeouts" {
  description = "Optional timeouts configuration for role definitions."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
    read   = optional(string)
  })
  default = {}
}
