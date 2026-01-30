# Core Role Assignment Variables
variable "name" {
  description = "Optional role assignment name (GUID). When omitted, Azure will generate one."
  type        = string
  default     = null

  validation {
    condition     = var.name == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.name))
    error_message = "name must be a valid GUID when provided."
  }
}

variable "scope" {
  description = "The scope at which the role assignment applies. Use a management group, subscription, resource group, or resource ID."
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
    error_message = "scope must be a valid ARM ID for management group, subscription, resource group, or resource scope."
  }
}

variable "principal_id" {
  description = "The principal (object) ID to assign the role to."
  type        = string

  validation {
    condition     = length(trimspace(var.principal_id)) > 0
    error_message = "principal_id must be a non-empty string."
  }
}

# Role Definition Configuration
variable "role_definition_id" {
  description = "The ID of the role definition to assign. Exactly one of role_definition_id or role_definition_name must be set."
  type        = string
  default     = null

  validation {
    condition     = var.role_definition_id == null || length(trimspace(var.role_definition_id)) > 0
    error_message = "role_definition_id must be a non-empty string when provided."
  }
}

variable "role_definition_name" {
  description = "The built-in role definition name to assign. Exactly one of role_definition_id or role_definition_name must be set."
  type        = string
  default     = null

  validation {
    condition     = var.role_definition_name == null || length(trimspace(var.role_definition_name)) > 0
    error_message = "role_definition_name must be a non-empty string when provided."
  }
}

# Principal Configuration
variable "principal_type" {
  description = "The principal type. Possible values are User, Group, or ServicePrincipal."
  type        = string
  default     = null

  validation {
    condition     = var.principal_type == null || contains(["User", "Group", "ServicePrincipal"], var.principal_type)
    error_message = "principal_type must be one of: User, Group, ServicePrincipal."
  }
}

# Optional Assignment Metadata
variable "description" {
  description = "Optional description for the role assignment."
  type        = string
  default     = null
}

variable "condition" {
  description = "Optional condition expression for the role assignment."
  type        = string
  default     = null

  validation {
    condition     = var.condition == null || length(trimspace(var.condition)) > 0
    error_message = "condition must be a non-empty string when provided."
  }
}

variable "condition_version" {
  description = "Condition version. Currently only 2.0 is supported when condition is used."
  type        = string
  default     = null

  validation {
    condition     = var.condition_version == null || contains(["2.0"], var.condition_version)
    error_message = "condition_version must be \"2.0\" when provided."
  }
}

variable "delegated_managed_identity_resource_id" {
  description = "Optional delegated managed identity resource ID (cross-tenant scenario)."
  type        = string
  default     = null

  validation {
    condition     = var.delegated_managed_identity_resource_id == null || length(trimspace(var.delegated_managed_identity_resource_id)) > 0
    error_message = "delegated_managed_identity_resource_id must be a non-empty string when provided."
  }
}

variable "skip_service_principal_aad_check" {
  description = "If true, skips the AAD check for service principals during assignment."
  type        = bool
  default     = false
}

variable "timeouts" {
  description = "Optional timeouts configuration for role assignments."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
    read   = optional(string)
  })
  default = {}
}
