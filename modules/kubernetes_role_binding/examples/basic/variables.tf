variable "namespace" {
  description = "Namespace where the role binding is created."
  type        = string
  default     = "intent-resolver"
}

variable "user_object_id" {
  description = "Example user object ID."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}
