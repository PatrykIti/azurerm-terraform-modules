# -----------------------------------------------------------------------------
# Agent Pools
# -----------------------------------------------------------------------------

variable "agent_pools" {
  description = "Map of Azure DevOps agent pools to manage."
  type = map(object({
    name           = optional(string)
    auto_provision = optional(bool)
    auto_update    = optional(bool)
    pool_type      = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for pool in values(var.agent_pools) : (
        pool.name == null || length(trimspace(pool.name)) > 0
      )
    ])
    error_message = "agent_pools.name must be a non-empty string when provided."
  }
}

# -----------------------------------------------------------------------------
# Agent Queues
# -----------------------------------------------------------------------------

variable "agent_queues" {
  description = "List of Azure DevOps agent queues to manage."
  type = list(object({
    project_id     = string
    name           = string
    agent_pool_id  = optional(string)
    agent_pool_key = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for queue in var.agent_queues : (
        (queue.agent_pool_id != null) != (queue.agent_pool_key != null)
      )
    ])
    error_message = "Each agent_queues entry must set exactly one of agent_pool_id or agent_pool_key."
  }

  validation {
    condition = alltrue([
      for queue in var.agent_queues : length(trimspace(queue.name)) > 0
    ])
    error_message = "agent_queues.name must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Elastic Pools
# -----------------------------------------------------------------------------

variable "elastic_pools" {
  description = "List of Azure DevOps elastic pools to manage."
  type = list(object({
    name                = string
    service_endpoint_id = string
    azure_resource_id   = string
    desired_idle        = optional(number)
    max_capacity        = number
  }))
  default = []

  validation {
    condition = alltrue([
      for pool in var.elastic_pools : length(trimspace(pool.name)) > 0
    ])
    error_message = "elastic_pools.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for pool in var.elastic_pools : pool.max_capacity > 0
    ])
    error_message = "elastic_pools.max_capacity must be greater than 0."
  }

  validation {
    condition = alltrue([
      for pool in var.elastic_pools : (
        pool.desired_idle == null || pool.desired_idle >= 0
      )
    ])
    error_message = "elastic_pools.desired_idle must be 0 or greater when provided."
  }

  validation {
    condition = alltrue([
      for pool in var.elastic_pools : (
        pool.desired_idle == null || pool.desired_idle <= pool.max_capacity
      )
    ])
    error_message = "elastic_pools.desired_idle cannot exceed max_capacity."
  }
}
