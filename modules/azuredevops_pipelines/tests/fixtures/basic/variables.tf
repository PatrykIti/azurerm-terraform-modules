variable "project_id" {
  type = string
}

variable "repo_name_prefix" {
  type    = string
  default = "ado-pipeline-repo"
}

variable "pipeline_name_prefix" {
  type    = string
  default = "ado-pipeline"
}

variable "yaml_path" {
  type    = string
  default = "azure-pipelines.yml"
}
