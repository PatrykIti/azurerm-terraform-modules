# -----------------------------------------------------------------------------
# Elastic Pool
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the Azure DevOps elastic pool."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "service_endpoint_id" {
  description = "ID of the service endpoint used by the elastic pool."
  type        = string

  validation {
    condition     = length(trimspace(var.service_endpoint_id)) > 0
    error_message = "service_endpoint_id must be a non-empty string."
  }
}

variable "service_endpoint_scope" {
  description = "Project ID that owns the service endpoint."
  type        = string

  validation {
    condition     = length(trimspace(var.service_endpoint_scope)) > 0
    error_message = "service_endpoint_scope must be a non-empty string."
  }
}

variable "azure_resource_id" {
  description = "Azure resource ID of the backing VMSS."
  type        = string

  validation {
    condition     = length(trimspace(var.azure_resource_id)) > 0
    error_message = "azure_resource_id must be a non-empty string."
  }
}

variable "desired_idle" {
  description = "Desired number of idle agents in the elastic pool."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_idle >= 0
    error_message = "desired_idle must be 0 or greater."
  }
}

variable "max_capacity" {
  description = "Maximum number of agents in the elastic pool."
  type        = number
  default     = 2

  validation {
    condition     = var.max_capacity > 0
    error_message = "max_capacity must be greater than 0."
  }

  validation {
    condition     = var.desired_idle <= var.max_capacity
    error_message = "desired_idle cannot exceed max_capacity."
  }
}

variable "recycle_after_each_use" {
  description = "Whether agents are recycled after each job."
  type        = bool
  default     = null
}

variable "time_to_live_minutes" {
  description = "Time-to-live for agents in minutes."
  type        = number
  default     = null

  validation {
    condition     = var.time_to_live_minutes == null || var.time_to_live_minutes >= 0
    error_message = "time_to_live_minutes must be 0 or greater when provided."
  }
}

variable "agent_interactive_ui" {
  description = "Whether interactive UI is enabled for agents."
  type        = bool
  default     = null
}

variable "auto_provision" {
  description = "Whether the elastic pool is automatically provisioned."
  type        = bool
  default     = null
}

variable "auto_update" {
  description = "Whether agents in the elastic pool are automatically updated."
  type        = bool
  default     = null
}

variable "project_id" {
  description = "Optional project ID for project-scoped elastic pool behavior."
  type        = string
  default     = null

  validation {
    condition     = var.project_id == null || length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string when provided."
  }
}
