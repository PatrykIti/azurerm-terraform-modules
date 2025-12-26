variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "kubernetes_api_url" {
  description = "Kubernetes API server URL."
  type        = string
  default     = "https://example.kubernetes.local"
}
