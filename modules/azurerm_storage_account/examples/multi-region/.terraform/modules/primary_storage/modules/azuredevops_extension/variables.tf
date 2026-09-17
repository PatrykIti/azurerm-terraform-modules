# -----------------------------------------------------------------------------
# Extension
# -----------------------------------------------------------------------------

variable "publisher_id" {
  description = "Publisher ID of the extension."
  type        = string

  validation {
    condition     = length(trimspace(var.publisher_id)) > 0
    error_message = "publisher_id must be a non-empty string."
  }
}

variable "extension_id" {
  description = "Extension ID from the Marketplace."
  type        = string

  validation {
    condition     = length(trimspace(var.extension_id)) > 0
    error_message = "extension_id must be a non-empty string."
  }
}

variable "extension_version" {
  description = "Optional extension version to pin."
  type        = string
  default     = null

  validation {
    condition     = var.extension_version == null || length(trimspace(var.extension_version)) > 0
    error_message = "extension_version must be a non-empty string when provided."
  }
}
