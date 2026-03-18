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
  description = "List of membership assignments for the module-managed group. Each item must include a unique key and at least one member descriptor."
  type = list(object({
    key                = string
    member_descriptors = list(string)
    mode               = optional(string, "add")
  }))
  default = []

  validation {
    condition = alltrue([
      for membership in var.group_memberships :
      trimspace(membership.key) != ""
    ])
    error_message = "group_memberships.key must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for membership in var.group_memberships : membership.key
    ])) == length(var.group_memberships)
    error_message = "group_memberships.key values must be unique."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships :
      length(membership.member_descriptors) > 0
    ])
    error_message = "Each group_membership must include at least one member descriptor."
  }

  validation {
    condition = alltrue(flatten([
      for membership in var.group_memberships : [
        for descriptor in membership.member_descriptors : trimspace(descriptor) != ""
      ]
    ]))
    error_message = "group_memberships.member_descriptors entries must be non-empty strings."
  }

  validation {
    condition = alltrue([
      for membership in var.group_memberships : contains(["add", "overwrite"], membership.mode)
    ])
    error_message = "group_memberships.mode must be one of: add, overwrite."
  }
}
