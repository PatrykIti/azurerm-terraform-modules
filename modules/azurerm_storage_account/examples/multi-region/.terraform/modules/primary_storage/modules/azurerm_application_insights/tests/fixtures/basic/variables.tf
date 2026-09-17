variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Tags to apply to Application Insights."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Basic"
  }
}

variable "enable_monitoring" {
  description = "Toggle monitoring configuration for performance tests."
  type        = bool
  default     = false
}

variable "enable_advanced_security" {
  description = "Toggle advanced security configuration for performance tests."
  type        = bool
  default     = false
}

variable "enable_backup" {
  description = "Toggle backup configuration for performance tests."
  type        = bool
  default     = false
}

variable "instance_count" {
  description = "Placeholder scale variable for performance tests."
  type        = number
  default     = 1
}
