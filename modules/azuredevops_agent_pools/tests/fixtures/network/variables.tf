variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "pool_name_prefix" {
  description = "Prefix for the external agent pool name."
  type        = string
  default     = "ado-agent-pool-network-fixture"
}

variable "queue_name_prefix" {
  description = "Prefix for the agent queue name."
  type        = string
  default     = "ado-agent-queue-network-fixture"
}
