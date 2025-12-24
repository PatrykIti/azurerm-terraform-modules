variable "project_id" {
  type = string
}

variable "environment_name_prefix" {
  type    = string
  default = "ado-env"
}

variable "kubernetes_api_url" {
  type    = string
  default = "https://example.kubernetes.local"
}
