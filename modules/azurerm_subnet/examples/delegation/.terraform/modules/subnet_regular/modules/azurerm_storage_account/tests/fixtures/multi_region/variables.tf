variable "primary_location" {
  type        = string
  description = "Primary Azure region for resources"
  default     = "West Europe"
}

variable "secondary_location" {
  type        = string
  description = "Secondary Azure region for resources"
  default     = "North Europe"
}

variable "random_suffix" {
  type        = string
  description = "Random suffix for resource naming"
  default     = ""
}