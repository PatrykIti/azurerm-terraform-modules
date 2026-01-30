variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "team_name_prefix" {
  description = "Prefix for the team name."
  type        = string
  default     = "ado-team-complete-example"
}
