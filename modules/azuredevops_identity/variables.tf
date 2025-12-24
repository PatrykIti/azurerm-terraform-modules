# -----------------------------------------------------------------------------
# Groups
# -----------------------------------------------------------------------------

variable "groups" {
  description = "Map of Azure DevOps groups to manage."
  type = map(object({
    scope        = optional(string)
    origin_id    = optional(string)
    origin       = optional(string)
    mail         = optional(string)
    display_name = optional(string)
    description  = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for group in values(var.groups) : (
        (group.origin_id != null && group.mail == null && group.display_name == null && group.scope == null) ||
        (group.mail != null && group.origin_id == null && group.display_name == null && group.scope == null) ||
        (group.origin_id == null && group.mail == null && group.display_name != null)
      )
    ])
    error_message = "Each group must set display_name (optionally with scope) or set origin_id or mail (without scope or display_name)."
  }
}

# -----------------------------------------------------------------------------
# Group Memberships
# -----------------------------------------------------------------------------

variable "group_memberships" {
  description = "List of group membership assignments."
  type = list(object({
    group_descriptor   = optional(string)
    group_key          = optional(string)
    member_descriptors = optional(list(string), [])
    member_group_keys  = optional(list(string), [])
    mode               = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for membership in var.group_memberships : (
        (membership.group_descriptor != null) != (membership.group_key != null)
      )
    ])
    error_message = "Each group_membership must set exactly one of group_descriptor or group_key."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships : (
        membership.mode == null || contains(["add", "overwrite"], membership.mode)
      )
    ])
    error_message = "group_memberships.mode must be one of: add, overwrite."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships : (
        length(try(membership.member_descriptors, [])) + length(try(membership.member_group_keys, [])) > 0
      )
    ])
    error_message = "Each group_membership must include at least one member descriptor or member group key."
  }
}

# -----------------------------------------------------------------------------
# Group Entitlements
# -----------------------------------------------------------------------------

variable "group_entitlements" {
  description = "List of group entitlements to manage."
  type = list(object({
    display_name         = optional(string)
    origin               = optional(string)
    origin_id            = optional(string)
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  }))
  default = []

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
}

# -----------------------------------------------------------------------------
# User Entitlements
# -----------------------------------------------------------------------------

variable "user_entitlements" {
  description = "List of user entitlements to manage."
  type = list(object({
    principal_name       = optional(string)
    origin_id            = optional(string)
    origin               = optional(string)
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  }))
  default = []

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
}

# -----------------------------------------------------------------------------
# Service Principal Entitlements
# -----------------------------------------------------------------------------

variable "service_principal_entitlements" {
  description = "List of service principal entitlements to manage."
  type = list(object({
    origin_id            = string
    origin               = optional(string)
    account_license_type = optional(string, "express")
    licensing_source     = optional(string, "account")
  }))
  default = []

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
}

# -----------------------------------------------------------------------------
# Security Role Assignments
# -----------------------------------------------------------------------------

variable "securityrole_assignments" {
  description = "List of security role assignments to manage."
  type = list(object({
    scope              = string
    resource_id        = string
    role_name          = string
    identity_id        = optional(string)
    identity_group_key = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments : (
        (assignment.identity_id != null) != (assignment.identity_group_key != null)
      )
    ])
    error_message = "Each securityrole_assignment must set exactly one of identity_id or identity_group_key."
  }
}
