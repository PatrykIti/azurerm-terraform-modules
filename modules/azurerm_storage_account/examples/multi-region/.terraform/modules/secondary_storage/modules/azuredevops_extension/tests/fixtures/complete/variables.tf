variable "extensions" {
  description = "List of extensions to install."
  type = list(object({
    publisher_id = string
    extension_id = string
    version      = optional(string)
  }))
}
