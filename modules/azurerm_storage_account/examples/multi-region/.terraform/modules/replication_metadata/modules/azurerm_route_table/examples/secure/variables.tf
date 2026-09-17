variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-rt-secure-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-rt-secure-example"
}

variable "subnet_workload_name" {
  description = "The name of the workload subnet"
  type        = string
  default     = "snet-workload-example"
}

variable "subnet_firewall_name" {
  description = "The name of the firewall subnet"
  type        = string
  default     = "snet-firewall-example"
}

variable "nva_nic_name" {
  description = "The name of the NVA network interface"
  type        = string
  default     = "nic-nva-example"
}

variable "route_table_name" {
  description = "The name of the route table"
  type        = string
  default     = "rt-secure-example"
}