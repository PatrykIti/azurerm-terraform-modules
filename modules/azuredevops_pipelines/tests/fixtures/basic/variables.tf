variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "random_suffix" {
  description = "A random suffix to ensure unique resource names."
  type        = string
}

variable "yaml_path" {
  description = "Path to the pipeline YAML file."
  type        = string
  default     = "azure-pipelines.yml"
}
