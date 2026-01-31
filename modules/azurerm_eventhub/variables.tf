variable "name" {
  description = "The name of the Event Hub."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-._a-zA-Z0-9]{0,254}[a-zA-Z0-9])?$", var.name))
    error_message = "The event hub name can contain only letters, numbers, periods (.), hyphens (-), and underscores (_), up to 256 characters, and it must begin and end with a letter or number."
  }
}

variable "namespace_id" {
  description = "The ID of the Event Hub Namespace. Prefer this over namespace_name/resource_group_name."
  type        = string
  default     = null

  validation {
    condition     = var.namespace_id == null || can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.EventHub/namespaces/[^/]+$", var.namespace_id))
    error_message = "namespace_id must be a valid Event Hub Namespace resource ID."
  }
}

variable "namespace_name" {
  description = "The name of the Event Hub Namespace (deprecated in provider; use namespace_id when possible)."
  type        = string
  default     = null

  validation {
    condition     = var.namespace_name == null || can(regex("^[a-zA-Z][-a-zA-Z0-9]{4,48}[a-zA-Z0-9]$", var.namespace_name))
    error_message = "The namespace name can contain only letters, numbers and hyphens. The namespace must start with a letter, and it must end with a letter or number and be between 6 and 50 characters long."
  }
}

variable "resource_group_name" {
  description = "The resource group name of the Event Hub Namespace (required when namespace_name is used)."
  type        = string
  default     = null
}

variable "partition_count" {
  description = "Specifies the number of partitions. Valid range is 1-1024 (dedicated cluster) or 1-32 (shared)."
  type        = number

  validation {
    condition     = var.partition_count >= 1 && var.partition_count <= 1024 && floor(var.partition_count) == var.partition_count
    error_message = "partition_count must be an integer between 1 and 1024."
  }
}

variable "message_retention" {
  description = "Specifies the number of days to retain events. Valid range is 1-90."
  type        = number
  default     = 1

  validation {
    condition     = var.message_retention == null || (var.message_retention >= 1 && var.message_retention <= 90 && floor(var.message_retention) == var.message_retention)
    error_message = "message_retention must be an integer between 1 and 90."
  }
}

variable "retention_description" {
  description = "Optional retention description configuration for the Event Hub."
  type = object({
    cleanup_policy                    = string
    retention_time_in_hours           = optional(number)
    tombstone_retention_time_in_hours = optional(number)
  })
  default = null

  validation {
    condition     = var.retention_description == null || contains(["Delete", "Compact"], var.retention_description.cleanup_policy)
    error_message = "retention_description.cleanup_policy must be Delete or Compact."
  }

  validation {
    condition = var.retention_description == null || (
      (var.retention_description.retention_time_in_hours == null) != (var.retention_description.tombstone_retention_time_in_hours == null)
    )
    error_message = "retention_description must set exactly one of retention_time_in_hours or tombstone_retention_time_in_hours."
  }

  validation {
    condition = var.retention_description == null || (
      (var.retention_description.cleanup_policy == "Delete" && var.retention_description.retention_time_in_hours != null) ||
      (var.retention_description.cleanup_policy == "Compact" && var.retention_description.tombstone_retention_time_in_hours != null)
    )
    error_message = "retention_description requires retention_time_in_hours for Delete or tombstone_retention_time_in_hours for Compact."
  }
}

variable "capture_description" {
  description = "Optional capture configuration for the Event Hub."
  type = object({
    enabled             = bool
    encoding            = string
    interval_in_seconds = optional(number, 300)
    size_limit_in_bytes = optional(number, 314572800)
    skip_empty_archives = optional(bool, false)
    destination = object({
      name                = optional(string, "EventHubArchive.AzureBlockBlob")
      storage_account_id  = string
      blob_container_name = string
      archive_name_format = string
    })
  })
  default = null

  validation {
    condition     = var.capture_description == null || contains(["Avro", "AvroDeflate"], var.capture_description.encoding)
    error_message = "capture_description.encoding must be Avro or AvroDeflate."
  }

  validation {
    condition = var.capture_description == null || (
      var.capture_description.interval_in_seconds >= 60 &&
      var.capture_description.interval_in_seconds <= 900 &&
      floor(var.capture_description.interval_in_seconds) == var.capture_description.interval_in_seconds
    )
    error_message = "capture_description.interval_in_seconds must be an integer between 60 and 900."
  }

  validation {
    condition = var.capture_description == null || (
      var.capture_description.size_limit_in_bytes >= 10485760 &&
      var.capture_description.size_limit_in_bytes <= 524288000 &&
      floor(var.capture_description.size_limit_in_bytes) == var.capture_description.size_limit_in_bytes
    )
    error_message = "capture_description.size_limit_in_bytes must be an integer between 10485760 and 524288000."
  }

  validation {
    condition     = var.capture_description == null || var.capture_description.destination.name == "EventHubArchive.AzureBlockBlob"
    error_message = "capture_description.destination.name must be EventHubArchive.AzureBlockBlob."
  }

  validation {
    condition = var.capture_description == null || alltrue([
      for token in ["{Namespace}", "{EventHub}", "{PartitionId}", "{Year}", "{Month}", "{Day}", "{Hour}", "{Minute}", "{Second}"] :
      strcontains(var.capture_description.destination.archive_name_format, token)
    ])
    error_message = "capture_description.destination.archive_name_format must include all required tokens: {Namespace},{EventHub},{PartitionId},{Year},{Month},{Day},{Hour},{Minute},{Second}."
  }
}

variable "status" {
  description = "Specifies the status of the Event Hub. Possible values are Active, Disabled, SendDisabled."
  type        = string
  default     = "Active"

  validation {
    condition     = contains(["Active", "Disabled", "SendDisabled"], var.status)
    error_message = "status must be one of: Active, Disabled, SendDisabled."
  }
}

variable "consumer_groups" {
  description = "Consumer groups to create for the Event Hub."
  type = list(object({
    name          = string
    user_metadata = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for group in var.consumer_groups : group.name])) == length(var.consumer_groups)
    error_message = "Each consumer_groups entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for group in var.consumer_groups :
      can(regex("^[a-zA-Z0-9]([-._a-zA-Z0-9]{0,48}[a-zA-Z0-9])?$", group.name))
    ])
    error_message = "Consumer group names must be 1-50 chars, start/end with alphanumeric, and contain only letters, numbers, periods, hyphens, or underscores."
  }
}

variable "authorization_rules" {
  description = "Authorization rules for the Event Hub."
  type = list(object({
    name   = string
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for rule in var.authorization_rules : rule.name])) == length(var.authorization_rules)
    error_message = "Each authorization_rules entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for rule in var.authorization_rules :
      can(regex("^[a-zA-Z0-9]([-._a-zA-Z0-9]{0,58}[a-zA-Z0-9])?$", rule.name))
    ])
    error_message = "Authorization rule names must be 1-60 chars, start/end with alphanumeric, and contain only letters, numbers, periods, hyphens, or underscores."
  }

  validation {
    condition = alltrue([
      for rule in var.authorization_rules :
      coalesce(rule.listen, false) || coalesce(rule.send, false) || coalesce(rule.manage, false)
    ])
    error_message = "Each authorization rule must enable at least one permission (listen, send, manage)."
  }

  validation {
    condition = alltrue([
      for rule in var.authorization_rules :
      !coalesce(rule.manage, false) || (coalesce(rule.listen, false) && coalesce(rule.send, false))
    ])
    error_message = "When manage is true, listen and send must also be true."
  }
}

variable "timeouts" {
  description = "Custom timeouts for the Event Hub resource."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
