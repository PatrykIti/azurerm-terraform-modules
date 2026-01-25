variable "server_id" {
  description = "Resource ID of the PostgreSQL Flexible Server hosting the database."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.server_id)) > 0
    error_message = "server_id must be a non-empty string."
  }
}

variable "name" {
  description = "PostgreSQL database name."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_-]{0,62}$", var.name))
    error_message = "name must be 1-63 characters, start with a lowercase letter or number, and contain only lowercase letters, numbers, hyphens, or underscores."
  }
}

variable "charset" {
  description = "Optional database charset (e.g. UTF8)."
  type        = string
  default     = null

  validation {
    condition     = var.charset == null || length(trimspace(var.charset)) > 0
    error_message = "charset must be a non-empty string when set."
  }
}

variable "collation" {
  description = "Optional database collation (e.g. en_US.utf8)."
  type        = string
  default     = null

  validation {
    condition     = var.collation == null || length(trimspace(var.collation)) > 0
    error_message = "collation must be a non-empty string when set."
  }
}
