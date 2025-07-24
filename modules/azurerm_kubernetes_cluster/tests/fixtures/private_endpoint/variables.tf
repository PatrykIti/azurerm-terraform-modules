variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "random_suffix" {
  description = "A random suffix to ensure unique resource names."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.30.5"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Test"
    Module      = "Private-Endpoint"
  }
}
