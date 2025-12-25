variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "pool_name_prefix" {
  description = "Prefix for the agent pool name."
  type        = string
  default     = "ado-agent-pool-basic-fixture"
}
