# Core Workbook Settings
variable "name" {
  description = "The name of the workbook. Must be a UUID (GUID)."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89aAbB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.name))
    error_message = "name must be a valid UUID (GUID)."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the workbook."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "The Azure region where the workbook should exist."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "display_name" {
  description = "The display name of the workbook."
  type        = string

  validation {
    condition     = length(trimspace(var.display_name)) > 0
    error_message = "display_name must not be empty."
  }
}

variable "data_json" {
  description = "The workbook content as a JSON string."
  type        = string

  validation {
    condition     = length(trimspace(var.data_json)) > 0
    error_message = "data_json must not be empty."
  }

  validation {
    condition     = can(jsondecode(var.data_json))
    error_message = "data_json must be valid JSON."
  }
}

# Optional metadata
variable "description" {
  description = "Optional description of the workbook."
  type        = string
  default     = null

  validation {
    condition     = var.description == null || length(trimspace(var.description)) > 0
    error_message = "description must not be empty when set."
  }
}

variable "category" {
  description = "Optional workbook category (for example: workbook, tsg, usage, Azure Monitor)."
  type        = string
  default     = null

  validation {
    condition = var.category == null || contains(
      ["workbook", "tsg", "usage", "azure monitor"],
      lower(var.category)
    )
    error_message = "category must be one of: workbook, tsg, usage, Azure Monitor."
  }
}

variable "source_id" {
  description = "Optional source resource ID used by the workbook."
  type        = string
  default     = null

  validation {
    condition     = var.source_id == null || can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/[^/]+/.+", var.source_id))
    error_message = "source_id must be a valid Azure resource ID when set."
  }
}

variable "storage_container_id" {
  description = "Optional storage container resource ID used by the workbook for backing storage."
  type        = string
  default     = null

  validation {
    condition = var.storage_container_id == null || can(regex(
      "(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Storage/storageAccounts/[^/]+/blobServices/default/containers/[^/]+$",
      var.storage_container_id
    ))
    error_message = "storage_container_id must be a valid Azure Storage container resource ID when set."
  }

  validation {
    condition     = var.storage_container_id == null || var.identity != null
    error_message = "identity must be configured when storage_container_id is set."
  }
}

variable "identity" {
  description = "Managed identity configuration for the workbook."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition     = var.identity == null || var.identity.type == "UserAssigned"
    error_message = "identity.type must be UserAssigned."
  }

  validation {
    condition     = var.identity == null || length(var.identity.identity_ids) > 0
    error_message = "identity.identity_ids must be provided when identity.type includes UserAssigned."
  }

  validation {
    condition     = var.identity == null || length(distinct(var.identity.identity_ids)) == length(var.identity.identity_ids)
    error_message = "identity.identity_ids must not contain duplicates."
  }

  validation {
    condition = var.identity == null || alltrue([
      for identity_id in var.identity.identity_ids :
      can(regex(
        "(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/[^/]+$",
        identity_id
      ))
    ])
    error_message = "identity.identity_ids must contain valid user-assigned identity resource IDs."
  }
}

variable "timeouts" {
  description = "Optional timeouts configuration for the workbook."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
    read   = optional(string)
  })
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
