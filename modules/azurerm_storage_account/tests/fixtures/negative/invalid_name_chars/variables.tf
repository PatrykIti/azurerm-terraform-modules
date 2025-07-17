variable "random_suffix" {
  description = "Random suffix for resource naming"
  type        = string
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "northeurope"
}
