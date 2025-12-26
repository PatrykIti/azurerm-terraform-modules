variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "repo_name" {
  description = "Name of the repository."
  type        = string
  default     = "ado-pipelines-repo-secure-example"
}

variable "pipeline_name" {
  description = "Name of the pipeline."
  type        = string
  default     = "ado-pipelines-secure-example"
}

variable "yaml_path" {
  description = "Path to the pipeline YAML file."
  type        = string
  default     = "azure-pipelines.yml"
}

variable "service_endpoint_name" {
  description = "Name of the service endpoint."
  type        = string
  default     = "ado-pipelines-endpoint-secure-example"
}

variable "service_endpoint_url" {
  description = "Service endpoint URL."
  type        = string
  default     = "https://example.endpoint.local"
}

variable "service_endpoint_username" {
  description = "Service endpoint username."
  type        = string
  default     = "example-user"
}

variable "service_endpoint_password" {
  description = "Service endpoint password."
  type        = string
  sensitive   = true
}
