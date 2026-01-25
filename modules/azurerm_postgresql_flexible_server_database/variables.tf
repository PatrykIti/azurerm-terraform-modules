# Server Configuration
variable "server" {
  description = <<-EOT
    PostgreSQL Flexible Server configuration for the database.

    id: Resource ID of the PostgreSQL Flexible Server hosting the database.
  EOT

  type = object({
    id = string
  })

  nullable = false

  validation {
    condition     = length(trimspace(var.server.id)) > 0
    error_message = "server.id must be a non-empty string."
  }
}

# Database Configuration
variable "database" {
  description = <<-EOT
    PostgreSQL database configuration.

    name: Database name.
    charset: Optional database charset (e.g. UTF8).
    collation: Optional database collation (e.g. en_US.utf8).
  EOT

  type = object({
    name      = string
    charset   = optional(string)
    collation = optional(string)
  })

  nullable = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_-]{0,62}$", var.database.name))
    error_message = "database.name must be 1-63 characters, start with a lowercase letter or number, and contain only lowercase letters, numbers, hyphens, or underscores."
  }

  validation {
    condition     = var.database.charset == null || length(trimspace(var.database.charset)) > 0
    error_message = "database.charset must be a non-empty string when set."
  }

  validation {
    condition     = var.database.collation == null || length(trimspace(var.database.collation)) > 0
    error_message = "database.collation must be a non-empty string when set."
  }
}
