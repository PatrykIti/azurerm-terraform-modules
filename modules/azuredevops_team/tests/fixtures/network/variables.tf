variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "team_name" {
  description = "Name of the team."
  type        = string
  default     = "ado-team-network-fixture"
}

variable "team_administrators" {
  description = "Optional team administrator assignments."
  type = list(object({
    key               = optional(string)
    team_id           = optional(string)
    team_key          = optional(string)
    admin_descriptors = list(string)
    mode              = optional(string, "add")
  }))
  default = []
}
