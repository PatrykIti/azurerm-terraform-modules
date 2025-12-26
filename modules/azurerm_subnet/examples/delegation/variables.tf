# Variables for Subnet Delegation Example

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-delegation-example"
}

variable "virtual_network_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "vnet-subnet-delegation-example"
}

variable "container_instances_subnet_name" {
  description = "The name of the Container Instances delegated subnet"
  type        = string
  default     = "snet-subnet-delegation-container-instances-example"
}

variable "postgresql_subnet_name" {
  description = "The name of the PostgreSQL delegated subnet"
  type        = string
  default     = "snet-subnet-delegation-postgresql-example"
}

variable "app_service_subnet_name" {
  description = "The name of the App Service delegated subnet"
  type        = string
  default     = "snet-subnet-delegation-app-service-example"
}

variable "batch_subnet_name" {
  description = "The name of the Batch delegated subnet"
  type        = string
  default     = "snet-subnet-delegation-batch-example"
}

variable "regular_subnet_name" {
  description = "The name of the regular (non-delegated) subnet"
  type        = string
  default     = "snet-subnet-delegation-regular-example"
}

variable "container_group_name" {
  description = "The name of the example Container Group"
  type        = string
  default     = "aci-subnet-delegation-example"
}
