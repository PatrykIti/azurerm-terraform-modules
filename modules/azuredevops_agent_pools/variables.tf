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
