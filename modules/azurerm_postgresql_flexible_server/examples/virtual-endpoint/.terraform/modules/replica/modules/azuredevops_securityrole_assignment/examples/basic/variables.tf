variable "resource_id" {
  description = "Target resource ID for the role assignment."
  type        = string
}

variable "scope" {
  description = "Security role scope ID."
  type        = string
}

variable "identity_id" {
  description = "Identity descriptor/ID to assign the role to."
  type        = string
}
