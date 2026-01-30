variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "cluster_location" {
  description = "Azure region for Log Analytics clusters."
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Tags to apply to Log Analytics Workspace."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Clusters"
  }
}
