# -----------------------------------------------------------------------------
# Agent Pool
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the Azure DevOps agent pool."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "auto_provision" {
  description = "Specifies whether a queue should be automatically provisioned for each project collection."
  type        = bool
  default     = false
}

variable "auto_update" {
  description = "Specifies whether agents within the pool should be automatically updated."
  type        = bool
  default     = true
}

variable "pool_type" {
  description = "Type of agent pool. Allowed values: automation, deployment."
  type        = string
  default     = "automation"

  validation {
    condition     = contains(["automation", "deployment"], var.pool_type)
    error_message = "pool_type must be one of: automation, deployment."
  }
}

# -----------------------------------------------------------------------------
# Elastic Pool
# -----------------------------------------------------------------------------

variable "elastic_pool" {
  description = "Elastic pool configuration. When null, elastic pool is not managed."
  type = object({
    name                   = string
    service_endpoint_id    = string
    service_endpoint_scope = string
    azure_resource_id      = string
    desired_idle           = number
    max_capacity           = number
    recycle_after_each_use = optional(bool)
    time_to_live_minutes   = optional(number)
    agent_interactive_ui   = optional(bool)
    auto_provision         = optional(bool)
    auto_update            = optional(bool)
    project_id             = optional(string)
  })
  default = null

  validation {
    condition     = var.elastic_pool == null || length(trimspace(var.elastic_pool.name)) > 0
    error_message = "elastic_pool.name must be a non-empty string when provided."
  }

  validation {
    condition     = var.elastic_pool == null || length(trimspace(var.elastic_pool.service_endpoint_id)) > 0
    error_message = "elastic_pool.service_endpoint_id must be a non-empty string when provided."
  }

  validation {
    condition     = var.elastic_pool == null || length(trimspace(var.elastic_pool.service_endpoint_scope)) > 0
    error_message = "elastic_pool.service_endpoint_scope must be a non-empty string when provided."
  }

  validation {
    condition     = var.elastic_pool == null || length(trimspace(var.elastic_pool.azure_resource_id)) > 0
    error_message = "elastic_pool.azure_resource_id must be a non-empty string when provided."
  }

  validation {
    condition     = var.elastic_pool == null || var.elastic_pool.max_capacity > 0
    error_message = "elastic_pool.max_capacity must be greater than 0."
  }

  validation {
    condition     = var.elastic_pool == null || var.elastic_pool.desired_idle >= 0
    error_message = "elastic_pool.desired_idle must be 0 or greater."
  }

  validation {
    condition     = var.elastic_pool == null || var.elastic_pool.desired_idle <= var.elastic_pool.max_capacity
    error_message = "elastic_pool.desired_idle cannot exceed max_capacity."
  }

  validation {
    condition     = var.elastic_pool == null || var.elastic_pool.time_to_live_minutes == null || var.elastic_pool.time_to_live_minutes >= 0
    error_message = "elastic_pool.time_to_live_minutes must be 0 or greater when provided."
  }
}
