variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "pool_name_prefix" {
  description = "Prefix for the agent pool name."
  type        = string
  default     = "ado-agent-pool-secure"
}

variable "queue_name" {
  description = "Name for the agent queue."
  type        = string
  default     = "ado-agent-queue-secure"
}
