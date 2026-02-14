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
# Generic Service Endpoint
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic" {
  description = "Generic service endpoint configuration managed by this module."
  type = object({
    service_endpoint_name = string
    server_url            = string
    username              = optional(string)
    password              = optional(string)
    description           = optional(string)
  })
  sensitive = true

  validation {
    condition = (
      length(trimspace(var.serviceendpoint_generic.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_generic.server_url)) > 0
    )
    error_message = "serviceendpoint_generic requires non-empty service_endpoint_name and server_url."
  }

  validation {
    condition = (
      var.serviceendpoint_generic.username == null || length(trimspace(var.serviceendpoint_generic.username)) > 0
      ) && (
      var.serviceendpoint_generic.password == null || length(trimspace(var.serviceendpoint_generic.password)) > 0
    )
    error_message = "serviceendpoint_generic.username and serviceendpoint_generic.password must be non-empty strings when provided."
  }
}

# -----------------------------------------------------------------------------
# Permissions (strict-child only)
# -----------------------------------------------------------------------------

variable "serviceendpoint_permissions" {
  description = "List of service endpoint permissions to assign to the endpoint created by this module."
  type = list(object({
    key         = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : (
        (permission.key == null || length(trimspace(permission.key)) > 0) &&
        length(trimspace(permission.principal)) > 0
      )
    ])
    error_message = "serviceendpoint_permissions.key and serviceendpoint_permissions.principal must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : length(permission.permissions) > 0
    ])
    error_message = "serviceendpoint_permissions.permissions must be a non-empty map."
  }

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : alltrue([
        for status in values(permission.permissions) : contains(["allow", "deny", "notset"], lower(status))
      ])
    ])
    error_message = "serviceendpoint_permissions.permissions values must be one of: Allow, Deny, NotSet."
  }

  validation {
    condition = length(var.serviceendpoint_permissions) == length(distinct([
      for permission in var.serviceendpoint_permissions : coalesce(permission.key, permission.principal)
    ]))
    error_message = "serviceendpoint_permissions entries must have unique keys (key or principal)."
  }
}
