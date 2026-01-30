variable "pool_name" {
  description = "Name of the agent pool."
  type        = string
  default     = "ado-agent-pools-complete-example"
}

variable "enable_elastic_pool" {
  description = "Whether to create an elastic pool in this example."
  type        = bool
  default     = false
}

variable "elastic_pool_name" {
  description = "Name of the elastic pool."
  type        = string
  default     = "ado-elastic-pool-complete-example"
}

variable "service_endpoint_id" {
  description = "Service endpoint ID for the elastic pool (required when enable_elastic_pool is true)."
  type        = string
  default     = ""
}

variable "service_endpoint_scope" {
  description = "Project ID that owns the service endpoint (required when enable_elastic_pool is true)."
  type        = string
  default     = ""
}

variable "azure_resource_id" {
  description = "Azure resource ID for the elastic pool (required when enable_elastic_pool is true)."
  type        = string
  default     = ""
}

variable "desired_idle" {
  description = "Desired number of idle agents in the elastic pool."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of agents in the elastic pool."
  type        = number
  default     = 5
}
