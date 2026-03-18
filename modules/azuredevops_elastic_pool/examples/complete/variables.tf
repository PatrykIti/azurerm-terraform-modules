variable "elastic_pool_name" {
  description = "Name of the elastic pool."
  type        = string
  default     = "ado-elastic-pool-complete-example"
}

variable "service_endpoint_id" {
  description = "Service endpoint ID used by the elastic pool."
  type        = string
  default     = "00000000-0000-0000-0000-000000000001"
}

variable "service_endpoint_scope" {
  description = "Project ID that owns the service endpoint."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "azure_resource_id" {
  description = "Azure VMSS resource ID used by the elastic pool."
  type        = string
  default     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/ado-rg/providers/Microsoft.Compute/virtualMachineScaleSets/ado-vmss"
}

variable "desired_idle" {
  description = "Desired idle agents."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum capacity."
  type        = number
  default     = 5
}

variable "recycle_after_each_use" {
  description = "Recycle each agent after use."
  type        = bool
  default     = false
}

variable "time_to_live_minutes" {
  description = "Agent TTL in minutes."
  type        = number
  default     = 60
}

variable "agent_interactive_ui" {
  description = "Enable interactive UI."
  type        = bool
  default     = false
}

variable "auto_provision" {
  description = "Enable auto provisioning."
  type        = bool
  default     = true
}

variable "auto_update" {
  description = "Enable auto update."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "Optional project ID."
  type        = string
  default     = null
}
