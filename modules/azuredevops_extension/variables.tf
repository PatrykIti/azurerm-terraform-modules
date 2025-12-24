# -----------------------------------------------------------------------------
# Extensions
# -----------------------------------------------------------------------------

variable "extensions" {
  description = "List of Azure DevOps Marketplace extensions to install."
  type = list(object({
    publisher_id = string
    extension_id = string
    version      = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for extension in var.extensions : (
        length(trimspace(extension.publisher_id)) > 0 &&
        length(trimspace(extension.extension_id)) > 0
      )
    ])
    error_message = "extensions entries must include non-empty publisher_id and extension_id."
  }

  validation {
    condition = alltrue([
      for extension in var.extensions : (
        extension.version == null || length(trimspace(extension.version)) > 0
      )
    ])
    error_message = "extensions.version must be a non-empty string when provided."
  }

  validation {
    condition = length(var.extensions) == length(distinct([
      for extension in var.extensions : "${extension.publisher_id}/${extension.extension_id}"
    ]))
    error_message = "extensions entries must be unique by publisher_id and extension_id."
  }
}
