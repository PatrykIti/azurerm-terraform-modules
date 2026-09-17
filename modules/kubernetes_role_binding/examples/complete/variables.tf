variable "namespace" {
  description = "Namespace where the role binding is created."
  type        = string
  default     = "intent-resolver"
}

variable "user_object_id_1" {
  description = "First example user object ID."
  type        = string
  default     = "00000000-0000-0000-0000-000000000001"
}

variable "user_object_id_2" {
  description = "Second example user object ID."
  type        = string
  default     = "00000000-0000-0000-0000-000000000002"
}
