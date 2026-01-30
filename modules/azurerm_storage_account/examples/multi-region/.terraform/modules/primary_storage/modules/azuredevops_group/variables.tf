# -----------------------------------------------------------------------------
# Group
# -----------------------------------------------------------------------------

variable "group_display_name" {
  description = "Display name (logical name) for a new Azure DevOps group. Exactly one of group_display_name, group_origin_id, or group_mail must be set."
  type        = string
  default     = null

  validation {
    condition     = var.group_display_name == null || trimspace(var.group_display_name) != ""
    error_message = "group_display_name must be a non-empty string when set."
  }

  validation {
    condition = length([
      for selector in [var.group_display_name, var.group_origin_id, var.group_mail] :
      selector
      if selector != null && trimspace(selector) != ""
    ]) == 1
    error_message = "Exactly one of group_display_name, group_origin_id, or group_mail must be set."
  }
}

variable "group_description" {
  description = "Optional description for the Azure DevOps group; stored only when creating a new group with display_name."
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
  description = "Optional Azure DevOps scope path for the group when creating it (ignored for existing groups). Must be used only with display_name (not with origin_id/mail)."
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
  description = "Origin ID of an existing external Azure DevOps group to attach instead of creating a new group (mutually exclusive with display_name/mail)."
  type        = string
  default     = null

  validation {
    condition     = var.group_origin_id == null || trimspace(var.group_origin_id) != ""
    error_message = "group_origin_id must be a non-empty string when set."
  }
}

variable "group_mail" {
  description = "Mail address selector for an existing external group to attach instead of creating a new group (mutually exclusive with display_name/origin_id)."
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
  description = "List of group membership assignments. Defaults to the module-managed group when group_descriptor is omitted; each item must include at least one member_descriptor and a stable key/descriptor."
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
  description = "List of group entitlements to manage for the target group. Each item must select by display_name or origin+origin_id; stable keys recommended."
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
