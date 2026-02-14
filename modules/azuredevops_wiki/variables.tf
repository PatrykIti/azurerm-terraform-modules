# -----------------------------------------------------------------------------
# Core
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Wiki
# -----------------------------------------------------------------------------

variable "wiki" {
  description = "Wiki configuration managed by this module instance."
  type = object({
    name          = string
    type          = string
    repository_id = optional(string)
    version       = optional(string)
    mapped_path   = optional(string)
  })

  validation {
    condition = (
      length(trimspace(var.wiki.name)) > 0 &&
      contains(["codeWiki", "projectWiki"], var.wiki.type)
    )
    error_message = "wiki.name must be non-empty and wiki.type must be codeWiki or projectWiki."
  }

  validation {
    condition = (
      var.wiki.repository_id == null || length(trimspace(var.wiki.repository_id)) > 0
      ) && (
      var.wiki.version == null || length(trimspace(var.wiki.version)) > 0
      ) && (
      var.wiki.mapped_path == null || length(trimspace(var.wiki.mapped_path)) > 0
    )
    error_message = "wiki.repository_id, wiki.version, and wiki.mapped_path must be non-empty strings when provided."
  }
}

# -----------------------------------------------------------------------------
# Wiki Pages (stable map keys)
# -----------------------------------------------------------------------------

variable "wiki_pages" {
  description = "Map of wiki pages keyed by a stable semantic key."
  type = map(object({
    path    = string
    content = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for page in values(var.wiki_pages) : length(trimspace(page.path)) > 0
    ])
    error_message = "wiki_pages.path must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for page in values(var.wiki_pages) : length(page.content) > 0
    ])
    error_message = "wiki_pages.content must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for page in values(var.wiki_pages) : page.path
    ])) == length(var.wiki_pages)
    error_message = "wiki_pages must have unique path values."
  }
}
