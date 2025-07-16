variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "example"
}

variable "network_ranges" {
  description = "IP ranges to allow network access"
  type        = list(string)
  default     = []
}

variable "enable_private_endpoints" {
  description = "Whether to enable private endpoints for storage services"
  type        = bool
  default     = true
}

variable "log_analytics_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}