# -----------------------------------------------------------------------------
# Group
# -----------------------------------------------------------------------------

variable "group_display_name" {
  description = "Display name for the Azure DevOps group. Required when creating a new group."
  type        = string
  default     = null

  validation {
    condition     = var.group_display_name == null || trimspace(var.group_display_name) != ""
    error_message = "group_display_name must be a non-empty string when set."
  }

  validation {
    condition = (
      (var.group_display_name == null && var.group_origin_id == null && var.group_mail == null) ||
      (var.group_display_name != null && var.group_origin_id == null && var.group_mail == null) ||
      (var.group_origin_id != null && var.group_display_name == null && var.group_mail == null) ||
      (var.group_mail != null && var.group_display_name == null && var.group_origin_id == null)
    )
    error_message = "Set either group_display_name (optionally with group_scope/description), group_origin_id, or group_mail. group_origin_id or group_mail cannot be combined with display_name."
  }
}

variable "group_description" {
  description = "Description for the Azure DevOps group. Only used when creating a new group."
  type        = string
  default     = null

  validation {
    condition     = var.group_description == null || trimspace(var.group_description) != ""
    error_message = "group_description must be a non-empty string when set."
  }

  validation {
    condition     = var.group_description == null || var.group_display_name != null
    error_message = "group_description can only be set when group_display_name is provided."
  }
}

variable "group_scope" {
  description = "Scope for the Azure DevOps group. Only valid when creating a new group."
  type        = string
  default     = null

  validation {
    condition     = var.group_scope == null || trimspace(var.group_scope) != ""
    error_message = "group_scope must be a non-empty string when set."
  }

  validation {
    condition     = var.group_scope == null || (var.group_display_name != null && var.group_origin_id == null && var.group_mail == null)
    error_message = "group_scope can only be set when group_display_name is provided and group_origin_id/group_mail are not set."
  }
}

variable "group_origin_id" {
  description = "Origin ID of an external group to attach instead of creating a new group."
  type        = string
  default     = null

  validation {
    condition     = var.group_origin_id == null || trimspace(var.group_origin_id) != ""
    error_message = "group_origin_id must be a non-empty string when set."
  }
}

variable "group_mail" {
  description = "Mail address of an external group to attach instead of creating a new group."
  type        = string
  default     = null

  validation {
    condition     = var.group_mail == null || trimspace(var.group_mail) != ""
    error_message = "group_mail must be a non-empty string when set."
  }
}

# -----------------------------------------------------------------------------
# Group Memberships
# -----------------------------------------------------------------------------

variable "group_memberships" {
  description = "List of group membership assignments."
  type = list(object({
    key                = optional(string)
    group_descriptor   = optional(string)
    member_descriptors = optional(list(string), [])
    mode               = optional(string, "add")
  }))
  default = []

  validation {
    condition = alltrue([
      for membership in var.group_memberships :
      membership.key == null || trimspace(membership.key) != ""
    ])
    error_message = "group_memberships.key must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships :
      membership.group_descriptor == null || trimspace(membership.group_descriptor) != ""
    ])
    error_message = "group_memberships.group_descriptor must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships :
      length(try(membership.member_descriptors, [])) > 0
    ])
    error_message = "Each group_membership must include at least one member descriptor."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships :
      membership.mode == null || contains(["add", "overwrite"], membership.mode)
    ])
    error_message = "group_memberships.mode must be one of: add, overwrite."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships :
      membership.group_descriptor != null || (var.group_display_name != null || var.group_origin_id != null || var.group_mail != null)
    ])
    error_message = "group_memberships.group_descriptor is required when the module group is not configured."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships :
      membership.group_descriptor != null || (membership.key != null && trimspace(membership.key) != "")
    ])
    error_message = "group_memberships.key is required when group_descriptor is omitted."
  }

  validation {
    condition = length(distinct([
      for membership in var.group_memberships :
      membership.key != null ? membership.key : membership.group_descriptor
      if membership.key != null || membership.group_descriptor != null
      ])) == length([
      for membership in var.group_memberships :
      membership.key != null ? membership.key : membership.group_descriptor
      if membership.key != null || membership.group_descriptor != null
    ])
    error_message = "group_memberships keys must be unique (derived from key or group_descriptor)."
  }
}

# -----------------------------------------------------------------------------
# Group Entitlements
# -----------------------------------------------------------------------------

variable "group_entitlements" {
  description = "List of group entitlements to manage."
  type = list(object({
    key                  = optional(string)
    display_name         = optional(string)
    origin               = optional(string)
    origin_id            = optional(string)
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  }))
  default = []

  validation {
    condition = alltrue([
      for entitlement in var.group_entitlements :
      entitlement.key == null || trimspace(entitlement.key) != ""
    ])
    error_message = "group_entitlements.key must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.group_entitlements :
      entitlement.display_name == null || trimspace(entitlement.display_name) != ""
    ])
    error_message = "group_entitlements.display_name must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.group_entitlements :
      entitlement.origin == null || trimspace(entitlement.origin) != ""
    ])
    error_message = "group_entitlements.origin must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.group_entitlements :
      entitlement.origin_id == null || trimspace(entitlement.origin_id) != ""
    ])
    error_message = "group_entitlements.origin_id must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.group_entitlements : (
        (entitlement.display_name != null && entitlement.origin_id == null && entitlement.origin == null) ||
        (entitlement.display_name == null && entitlement.origin_id != null && entitlement.origin != null)
      )
    ])
    error_message = "Each group_entitlement must set display_name or origin+origin_id, but not both."
  }

  validation {
    condition = alltrue([
      for entitlement in var.group_entitlements : contains([
        "advanced",
        "earlyAdopter",
        "express",
        "none",
        "professional",
        "stakeholder",
        "basic"
      ], entitlement.account_license_type)
    ])
    error_message = "group_entitlements.account_license_type must be a valid Azure DevOps license type."
  }

  validation {
    condition = alltrue([
      for entitlement in var.group_entitlements : contains([
        "account",
        "auto",
        "msdn",
        "none",
        "profile",
        "trial"
      ], entitlement.licensing_source)
    ])
    error_message = "group_entitlements.licensing_source must be a valid licensing source."
  }

  validation {
    condition = length(distinct([
      for entitlement in var.group_entitlements : coalesce(entitlement.key, entitlement.display_name, entitlement.origin_id)
    ])) == length(var.group_entitlements)
    error_message = "group_entitlements keys must be unique (derived from key, display_name, or origin_id)."
  }
}

# -----------------------------------------------------------------------------
# User Entitlements
# -----------------------------------------------------------------------------

variable "user_entitlements" {
  description = "List of user entitlements to manage."
  type = list(object({
    key                  = optional(string)
    principal_name       = optional(string)
    origin_id            = optional(string)
    origin               = optional(string)
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  }))
  default = []

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements :
      entitlement.key == null || trimspace(entitlement.key) != ""
    ])
    error_message = "user_entitlements.key must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements :
      entitlement.principal_name == null || trimspace(entitlement.principal_name) != ""
    ])
    error_message = "user_entitlements.principal_name must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements :
      entitlement.origin == null || trimspace(entitlement.origin) != ""
    ])
    error_message = "user_entitlements.origin must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements :
      entitlement.origin_id == null || trimspace(entitlement.origin_id) != ""
    ])
    error_message = "user_entitlements.origin_id must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements : (
        (entitlement.principal_name != null && entitlement.origin_id == null && entitlement.origin == null) ||
        (entitlement.principal_name == null && entitlement.origin_id != null && entitlement.origin != null)
      )
    ])
    error_message = "Each user_entitlement must set principal_name or origin+origin_id, but not both."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements : contains([
        "advanced",
        "earlyAdopter",
        "express",
        "none",
        "professional",
        "stakeholder",
        "basic"
      ], entitlement.account_license_type)
    ])
    error_message = "user_entitlements.account_license_type must be a valid Azure DevOps license type."
  }

  validation {
    condition = alltrue([
      for entitlement in var.user_entitlements : contains([
        "account",
        "auto",
        "msdn",
        "none",
        "profile",
        "trial"
      ], entitlement.licensing_source)
    ])
    error_message = "user_entitlements.licensing_source must be a valid licensing source."
  }

  validation {
    condition = length(distinct([
      for entitlement in var.user_entitlements : coalesce(entitlement.key, entitlement.principal_name, entitlement.origin_id)
    ])) == length(var.user_entitlements)
    error_message = "user_entitlements keys must be unique (derived from key, principal_name, or origin_id)."
  }
}

# -----------------------------------------------------------------------------
# Service Principal Entitlements
# -----------------------------------------------------------------------------

variable "service_principal_entitlements" {
  description = "List of service principal entitlements to manage."
  type = list(object({
    key                  = optional(string)
    origin_id            = string
    origin               = optional(string, "aad")
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  }))
  default = []

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements :
      entitlement.key == null || trimspace(entitlement.key) != ""
    ])
    error_message = "service_principal_entitlements.key must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements :
      trimspace(entitlement.origin_id) != ""
    ])
    error_message = "service_principal_entitlements.origin_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements : (
        entitlement.origin == null || entitlement.origin == "aad"
      )
    ])
    error_message = "service_principal_entitlements.origin must be \"aad\" when set."
  }

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements : contains([
        "advanced",
        "earlyAdopter",
        "express",
        "none",
        "professional",
        "stakeholder",
        "basic"
      ], entitlement.account_license_type)
    ])
    error_message = "service_principal_entitlements.account_license_type must be a valid Azure DevOps license type."
  }

  validation {
    condition = alltrue([
      for entitlement in var.service_principal_entitlements : contains([
        "account",
        "auto",
        "msdn",
        "none",
        "profile",
        "trial"
      ], entitlement.licensing_source)
    ])
    error_message = "service_principal_entitlements.licensing_source must be a valid licensing source."
  }

  validation {
    condition = length(distinct([
      for entitlement in var.service_principal_entitlements : coalesce(entitlement.key, entitlement.origin_id)
    ])) == length(var.service_principal_entitlements)
    error_message = "service_principal_entitlements keys must be unique (derived from key or origin_id)."
  }
}

# -----------------------------------------------------------------------------
# Security Role Assignments
# -----------------------------------------------------------------------------

variable "securityrole_assignments" {
  description = "List of security role assignments to manage."
  type = list(object({
    key         = optional(string)
    scope       = string
    resource_id = string
    role_name   = string
    identity_id = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      assignment.key == null || trimspace(assignment.key) != ""
    ])
    error_message = "securityrole_assignments.key must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      trimspace(assignment.scope) != ""
    ])
    error_message = "securityrole_assignments.scope must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      trimspace(assignment.resource_id) != ""
    ])
    error_message = "securityrole_assignments.resource_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      trimspace(assignment.role_name) != ""
    ])
    error_message = "securityrole_assignments.role_name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      assignment.identity_id == null || trimspace(assignment.identity_id) != ""
    ])
    error_message = "securityrole_assignments.identity_id must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      assignment.identity_id != null || (var.group_display_name != null || var.group_origin_id != null || var.group_mail != null)
    ])
    error_message = "securityrole_assignments.identity_id is required when the module group is not configured."
  }

  validation {
    condition = length(distinct([
      for assignment in var.securityrole_assignments : coalesce(
        assignment.key,
        assignment.identity_id,
        "${assignment.scope}/${assignment.resource_id}/${assignment.role_name}"
      )
    ])) == length(var.securityrole_assignments)
    error_message = "securityrole_assignments keys must be unique (derived from key, identity_id, or scope/resource/role)."
  }
}
