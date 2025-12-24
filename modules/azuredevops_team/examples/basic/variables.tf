variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "team_name_prefix" {
  description = "Prefix for the team name."
  type        = string
  default     = "ado-team-basic"
}

variable "member_descriptors" {
  description = "Optional member descriptors to add to the team."
  type        = list(string)
  default     = []
}
