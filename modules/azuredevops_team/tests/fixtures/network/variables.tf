variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "random_suffix" {
  description = "Random suffix to ensure unique team names."
  type        = string
  default     = "local"
}

variable "team_administrators" {
  description = "Optional team administrator assignments."
  type = list(object({
    key               = string
    admin_descriptors = list(string)
    mode              = optional(string, "add")
  }))
  default = []
}
