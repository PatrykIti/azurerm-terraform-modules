variable "name" {
  description = "The name of the Private DNS Zone Virtual Network Link."
  type        = string

  validation {
    condition = (
      length(var.name) >= 1 &&
      length(var.name) <= 80 &&
      can(regex("^[A-Za-z0-9]([A-Za-z0-9-_.]{0,78}[A-Za-z0-9])?$", var.name))
    )
    error_message = "name must be 1-80 characters, start and end with an alphanumeric character, and contain only letters, numbers, hyphens, underscores, or periods."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group containing the Private DNS Zone."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must be a non-empty string."
  }
}

variable "private_dns_zone_name" {
  description = "The name of the Private DNS Zone (without a trailing dot)."
  type        = string

  validation {
    condition = (
      length(var.private_dns_zone_name) >= 1 &&
      length(var.private_dns_zone_name) <= 253 &&
      !endswith(var.private_dns_zone_name, ".") &&
      alltrue([
        for label in split(".", var.private_dns_zone_name) : can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$", label))
      ])
    )
    error_message = "private_dns_zone_name must be a valid DNS zone name (1-253 chars, labels 1-63 chars, alphanumeric with hyphens, no trailing dot)."
  }
}

variable "virtual_network_id" {
  description = "The ID of the Virtual Network to link to the Private DNS Zone."
  type        = string

  validation {
    condition     = can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.virtual_network_id))
    error_message = "virtual_network_id must be a valid Azure Virtual Network resource ID."
  }
}

variable "registration_enabled" {
  description = "Whether auto-registration of virtual machine records in the linked virtual network is enabled."
  type        = bool
  default     = false
}

variable "resolution_policy" {
  description = "Optional DNS resolution policy for the link. Accepted values are Default or NxDomainRedirect."
  type        = string
  default     = null

  validation {
    condition     = var.resolution_policy == null || contains(["Default", "NxDomainRedirect"], var.resolution_policy)
    error_message = "resolution_policy must be either Default or NxDomainRedirect when set."
  }
}

variable "timeouts" {
  description = "Timeout configuration for creating, reading, updating, and deleting the Virtual Network Link."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
