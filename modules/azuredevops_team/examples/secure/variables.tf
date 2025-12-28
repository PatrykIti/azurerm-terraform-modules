variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "team_name" {
  description = "Name of the team."
  type        = string
  default     = "ado-team-secure-example"
}
