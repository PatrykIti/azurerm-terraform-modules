variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "random_suffix" {
  description = "Random suffix for unique resource names"
  type        = string
  default     = ""
}

variable "tag_environment" {
  description = "Environment tag for resources"
  type        = string
  default     = "Development"
}

variable "service_endpoints" {
  description = "List of Service endpoints to associate with the subnet"
  type        = list(string)
  default     = []
}

variable "enforce_private_link_endpoint_network_policies" {
  description = "Enable or Disable network policies for the private link endpoint on the subnet"
  type        = bool
  default     = true
}
