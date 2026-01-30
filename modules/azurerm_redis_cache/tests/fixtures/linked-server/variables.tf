variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for the primary Redis Cache."
  type        = string
  default     = "westeurope"
}

variable "secondary_location" {
  description = "Azure region for the secondary Redis Cache."
  type        = string
  default     = "northeurope"
}

variable "tags" {
  description = "Tags to apply to Redis Cache."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Linked-Server"
  }
}
