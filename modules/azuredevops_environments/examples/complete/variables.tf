variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "environment_name_prefix" {
  description = "Prefix for the environment name."
  type        = string
  default     = "ado-env"
}

variable "kubernetes_api_url" {
  description = "Kubernetes API server URL."
  type        = string
  default     = "https://example.kubernetes.local"
}
