variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "team_name" {
  description = "Name of the team."
  type        = string
  default     = "ado-team-basic-example"
}

variable "member_descriptors" {
  description = "Optional member descriptors to add to the team."
  type        = list(string)
  default     = []
}
