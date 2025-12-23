variable "security_role_assignments" {
  description = "Optional security role assignments to test."
  type = list(object({
    scope              = string
    resource_id        = string
    role_name          = string
    identity_id        = optional(string)
    identity_group_key = optional(string)
  }))
  default = []
}
