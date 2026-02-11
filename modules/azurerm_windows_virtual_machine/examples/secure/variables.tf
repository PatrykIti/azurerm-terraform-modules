variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-win-vm-secure-example"
}

variable "rdp_allowed_cidrs" {
  description = "List of CIDR ranges allowed to access RDP (3389)."
  type        = list(string)
  default     = ["203.0.113.0/32"]
}
