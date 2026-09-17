variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "kind" {
  description = "The kind of the Data Collection Endpoint."
  type        = string
  default     = "Linux"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Data Collection Endpoint."
  type        = bool
  default     = true
}

variable "description" {
  description = "Description for the Data Collection Endpoint."
  type        = string
  default     = "Complete Data Collection Endpoint fixture."
}

variable "tags" {
  description = "Tags to apply to the Data Collection Endpoint."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Complete"
  }
}
