variable "name" {
  description = "The name of the Private DNS Zone (for example: privatelink.blob.core.windows.net)."
  type        = string

  validation {
    condition = (
      length(var.name) >= 1 &&
      length(var.name) <= 253 &&
      !endswith(var.name, ".") &&
      alltrue([
        for label in split(".", var.name) : can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$", label))
      ])
    )
    error_message = "name must be a valid DNS zone name (1-253 chars, labels 1-63 chars, alphanumeric with hyphens, no trailing dot)."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Private DNS Zone."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must be a non-empty string."
  }
}

variable "soa_record" {
  description = <<-EOT
    Optional SOA record settings for the Private DNS Zone.

    When set, email is required. Time values are expressed in seconds.
  EOT
  type = object({
    email        = string
    expire_time  = optional(number)
    minimum_ttl  = optional(number)
    refresh_time = optional(number)
    retry_time   = optional(number)
    ttl          = optional(number)
    tags         = optional(map(string))
  })
  default = null

  validation {
    condition     = var.soa_record == null || length(trimspace(var.soa_record.email)) > 0
    error_message = "soa_record.email must be a non-empty string when soa_record is set."
  }

  validation {
    condition = var.soa_record == null || alltrue([
      for value in [
        var.soa_record.expire_time,
        var.soa_record.minimum_ttl,
        var.soa_record.refresh_time,
        var.soa_record.retry_time,
        var.soa_record.ttl
      ] : value == null || (value >= 0 && value <= 2147483647 && value == floor(value))
    ])
    error_message = "soa_record time fields must be whole numbers between 0 and 2147483647 when set."
  }
}

variable "timeouts" {
  description = "Timeout configuration for creating, reading, updating, and deleting the Private DNS Zone."
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
