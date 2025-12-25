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
# Wikis
# -----------------------------------------------------------------------------

variable "wikis" {
  description = "Map of wikis to manage."
  type = map(object({
    name          = optional(string)
    type          = string
    repository_id = optional(string)
    version       = optional(string)
    mapped_path   = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for wiki in values(var.wikis) : (
        wiki.name == null || length(trimspace(wiki.name)) > 0
      )
    ])
    error_message = "wikis.name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for wiki in values(var.wikis) : contains(["codeWiki", "projectWiki"], wiki.type)
    ])
    error_message = "wikis.type must be codeWiki or projectWiki."
  }
}

# -----------------------------------------------------------------------------
# Wiki Pages
# -----------------------------------------------------------------------------

variable "wiki_pages" {
  description = "List of wiki pages to manage."
  type = list(object({
    wiki_id  = optional(string)
    wiki_key = optional(string)
    path     = string
    content  = string
  }))
  default = []

  validation {
    condition = alltrue([
      for page in var.wiki_pages : (
        (page.wiki_id != null) != (page.wiki_key != null)
      )
    ])
    error_message = "wiki_pages must set exactly one of wiki_id or wiki_key."
  }

  validation {
    condition = alltrue([
      for page in var.wiki_pages : length(trimspace(page.path)) > 0
    ])
    error_message = "wiki_pages.path must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for page in var.wiki_pages : length(page.content) > 0
    ])
    error_message = "wiki_pages.content must be a non-empty string."
  }
}
