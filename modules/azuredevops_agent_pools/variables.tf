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
# Agent Queues
# -----------------------------------------------------------------------------

variable "agent_queues" {
  description = <<-EOT
    List of Azure DevOps agent queues to manage.
    - When name is provided, agent_pool_id must be null (queue resolved by name).
    - When agent_pool_id is provided, name must be null (queue name derived from the pool).
    - When both are null, the module uses the created agent pool ID.
    - When auto_provision is true, do not omit both name and agent_pool_id.
  EOT
  type = list(object({
    key           = optional(string)
    project_id    = string
    name          = optional(string)
    agent_pool_id = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for agent_queue in var.agent_queues : length(trimspace(agent_queue.project_id)) > 0
    ])
    error_message = "agent_queues.project_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for agent_queue in var.agent_queues : (
        (agent_queue.name == null || length(trimspace(agent_queue.name)) > 0) &&
        (agent_queue.key == null || length(trimspace(agent_queue.key)) > 0)
      )
    ])
    error_message = "agent_queues key/name must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for agent_queue in var.agent_queues : (
        agent_queue.agent_pool_id == null || agent_queue.agent_pool_id > 0
      )
    ])
    error_message = "agent_queues.agent_pool_id must be greater than 0 when provided."
  }

  validation {
    condition = alltrue([
      for agent_queue in var.agent_queues : !(agent_queue.name != null && agent_queue.agent_pool_id != null)
    ])
    error_message = "Each agent_queues entry must set at most one of name or agent_pool_id."
  }

  validation {
    condition = length(distinct([
      for agent_queue in var.agent_queues :
      coalesce(
        agent_queue.key,
        agent_queue.name,
        agent_queue.agent_pool_id == null ? null : tostring(agent_queue.agent_pool_id),
        agent_queue.project_id
      )
    ])) == length(var.agent_queues)
    error_message = "agent_queues keys must be unique; set key when name/agent_pool_id/project_id would collide."
  }

  validation {
    condition = !var.auto_provision || alltrue([
      for agent_queue in var.agent_queues : !(
        agent_queue.agent_pool_id == null &&
        agent_queue.name == null
      )
    ])
    error_message = "When auto_provision is true, agent_queues must set name or agent_pool_id."
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
