variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "node_count" {
  description = "AKS node count for the fixture."
  type        = number
  default     = 1
}
