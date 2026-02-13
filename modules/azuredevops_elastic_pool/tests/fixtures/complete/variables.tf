variable "elastic_pool_name_prefix" {
  description = "Prefix for the elastic pool name."
  type        = string
  default     = "ado-elastic-pool-complete-fixture"
}

variable "service_endpoint_id" {
  description = "Service endpoint ID used by the elastic pool."
  type        = string
}

variable "service_endpoint_scope" {
  description = "Project ID that owns the service endpoint."
  type        = string
}

variable "azure_resource_id" {
  description = "Azure VMSS resource ID used by the elastic pool."
  type        = string
}
