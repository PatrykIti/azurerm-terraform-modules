variable "project_id" {
  type = string
}

variable "repo_name_prefix" {
  type    = string
  default = "ado-network-repo"
}

variable "pipeline_name_prefix" {
  type    = string
  default = "ado-network-pipeline"
}

variable "yaml_path" {
  type    = string
  default = "azure-pipelines.yml"
}
