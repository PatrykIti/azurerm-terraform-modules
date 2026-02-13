variable "elastic_pool_name" {
  description = "Name of the elastic pool."
  type        = string
  default     = "ado-elastic-pool-basic-example"
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
