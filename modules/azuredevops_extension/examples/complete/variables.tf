variable "extensions" {
  description = "List of extensions to install."
  type = list(object({
    publisher_id = string
    extension_id = string
    version      = optional(string)
  }))
  default = [
    {
      publisher_id = "publisher-one"
      extension_id = "extension-one"
    },
    {
      publisher_id = "publisher-two"
      extension_id = "extension-two"
      version      = "1.2.3"
    }
  ]
}
