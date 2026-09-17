variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "ingestion_access_mode" {
  description = "Access mode for ingestion."
  type        = string
  default     = "PrivateOnly"
}

variable "query_access_mode" {
  description = "Access mode for query."
  type        = string
  default     = "PrivateOnly"
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Basic"
  }
}
