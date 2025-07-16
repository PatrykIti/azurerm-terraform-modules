variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.27.9"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Test"
    Module      = "Private-Endpoint"
  }
}
