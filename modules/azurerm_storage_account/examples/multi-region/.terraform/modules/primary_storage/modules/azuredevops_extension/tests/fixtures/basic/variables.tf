variable "publisher_id" {
  description = "Publisher ID of the extension."
  type        = string
}

variable "extension_id" {
  description = "Extension ID from the Marketplace."
  type        = string
}

variable "extension_version" {
  description = "Optional extension version to pin."
  type        = string
  default     = null
}
