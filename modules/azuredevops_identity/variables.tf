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
    key                = optional(string)
    group_descriptor   = optional(string)
    group_key          = optional(string)
    member_descriptors = optional(list(string), [])
    member_group_keys  = optional(list(string), [])
    mode               = optional(string, "add")
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

  validation {
    condition = alltrue([
      for membership in var.group_memberships : (
        membership.group_key == null || contains(keys(var.groups), membership.group_key)
      )
    ])
    error_message = "group_memberships.group_key must reference a key in groups."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships : alltrue([
        for key in try(membership.member_group_keys, []) : contains(keys(var.groups), key)
      ])
    ])
    error_message = "group_memberships.member_group_keys must reference keys in groups."
  }

  validation {
    condition = length(distinct([
      for membership in var.group_memberships : coalesce(membership.key, membership.group_descriptor, membership.group_key)
    ])) == length(var.group_memberships)
    error_message = "group_memberships keys must be unique (derived from key, group_descriptor, or group_key)."
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
    key                = optional(string)
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

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments : (
        assignment.identity_group_key == null || contains(keys(var.groups), assignment.identity_group_key)
      )
    ])
    error_message = "securityrole_assignments.identity_group_key must reference a key in groups."
  }

  validation {
    condition = length(distinct([
      for assignment in var.securityrole_assignments : coalesce(
        assignment.key,
        "${assignment.scope}/${assignment.resource_id}/${assignment.role_name}/${coalesce(assignment.identity_id, assignment.identity_group_key, "unknown")}"
      )
    ])) == length(var.securityrole_assignments)
    error_message = "securityrole_assignments keys must be unique (derived from key or scope/resource/role/identity)."
  }
}
