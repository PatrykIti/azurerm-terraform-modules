variable "project_id" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "kubernetes_api_url" {
  type    = string
  default = "https://example.kubernetes.local"
}
