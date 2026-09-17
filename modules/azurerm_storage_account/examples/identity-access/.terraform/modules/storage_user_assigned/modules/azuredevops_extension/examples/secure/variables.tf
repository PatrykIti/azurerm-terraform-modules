variable "approved_extensions" {
  description = "Allowlist of approved extensions to install."
  type = list(object({
    publisher_id = string
    extension_id = string
    version      = optional(string)
  }))
  default = [
    {
      publisher_id = "approved-publisher"
      extension_id = "approved-extension"
    }
  ]
}
