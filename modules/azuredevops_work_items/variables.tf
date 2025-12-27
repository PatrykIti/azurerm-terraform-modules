# -----------------------------------------------------------------------------
# Core
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Default Azure DevOps project ID for project-scoped resources."
  type        = string
  default     = null

  validation {
    condition     = var.project_id == null || length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string when provided."
  }
}

# -----------------------------------------------------------------------------
# Processes
# -----------------------------------------------------------------------------

variable "processes" {
  description = "Map of work item processes to manage."
  type = map(object({
    name                   = optional(string)
    parent_process_type_id = string
    description            = optional(string)
    is_default             = optional(bool)
    is_enabled             = optional(bool)
    reference_name         = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for process in values(var.processes) : (
        (process.name == null || length(trimspace(process.name)) > 0) &&
        (process.reference_name == null || length(trimspace(process.reference_name)) > 0)
      )
    ])
    error_message = "processes.name and processes.reference_name must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for process in values(var.processes) : length(trimspace(process.parent_process_type_id)) > 0
    ])
    error_message = "processes.parent_process_type_id must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Work Items
# -----------------------------------------------------------------------------

variable "work_items" {
  description = "List of work items to manage. parent_key must reference a top-level work item (no parent_key)."
  type = list(object({
    key            = optional(string)
    project_id     = optional(string)
    title          = string
    type           = string
    state          = optional(string)
    tags           = optional(list(string))
    area_path      = optional(string)
    iteration_path = optional(string)
    parent_id      = optional(number)
    parent_key     = optional(string)
    custom_fields  = optional(map(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for item in var.work_items : (
        (item.key == null || length(trimspace(item.key)) > 0) &&
        (item.project_id == null || length(trimspace(item.project_id)) > 0)
      )
    ])
    error_message = "work_items.key and work_items.project_id must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for item in var.work_items : length(trimspace(item.title)) > 0
    ])
    error_message = "work_items.title must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for item in var.work_items : length(trimspace(item.type)) > 0
    ])
    error_message = "work_items.type must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for item in var.work_items : (
        item.parent_id == null || item.parent_id > 0
      )
    ])
    error_message = "work_items.parent_id must be a positive number when provided."
  }

  validation {
    condition = alltrue([
      for item in var.work_items : (
        item.parent_key == null || length(trimspace(item.parent_key)) > 0
      )
    ])
    error_message = "work_items.parent_key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for item in var.work_items : (
        item.parent_id == null || item.parent_key == null
      )
    ])
    error_message = "work_items must not set both parent_id and parent_key."
  }

  validation {
    condition = alltrue([
      for item in var.work_items : (
        item.parent_key == null ||
        contains([
          for candidate in var.work_items : coalesce(candidate.key, candidate.title)
          if candidate.parent_key == null
        ], item.parent_key)
      )
    ])
    error_message = "work_items.parent_key must reference a top-level work item key (parent_key unset)."
  }

  validation {
    condition = length(distinct([
      for item in var.work_items : coalesce(item.key, item.title)
    ])) == length(var.work_items)
    error_message = "work_items entries must have unique keys (key/title)."
  }

  validation {
    condition = alltrue([
      for item in var.work_items : (
        item.project_id != null ||
        (var.project_id != null && length(trimspace(var.project_id)) > 0)
      )
    ])
    error_message = "work_items require project_id either on the item or via the module default."
  }
}

# -----------------------------------------------------------------------------
# Query Folders
# -----------------------------------------------------------------------------

variable "query_folders" {
  description = "List of work item query folders to manage. parent_key must reference a top-level folder (no parent_key)."
  type = list(object({
    key        = optional(string)
    project_id = optional(string)
    name       = string
    area       = optional(string)
    parent_id  = optional(number)
    parent_key = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for folder in var.query_folders : (
        (folder.key == null || length(trimspace(folder.key)) > 0) &&
        (folder.project_id == null || length(trimspace(folder.project_id)) > 0)
      )
    ])
    error_message = "query_folders.key and query_folders.project_id must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for folder in var.query_folders : length(trimspace(folder.name)) > 0
    ])
    error_message = "query_folders.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for folder in var.query_folders : (
        folder.area == null || length(trimspace(folder.area)) > 0
      )
    ])
    error_message = "query_folders.area must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for folder in var.query_folders : (
        folder.parent_id == null || folder.parent_id > 0
      )
    ])
    error_message = "query_folders.parent_id must be a positive number when provided."
  }

  validation {
    condition = alltrue([
      for folder in var.query_folders : (
        folder.parent_key == null || length(trimspace(folder.parent_key)) > 0
      )
    ])
    error_message = "query_folders.parent_key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for folder in var.query_folders : (
        length(compact([folder.area, folder.parent_key])) + (folder.parent_id != null ? 1 : 0) == 1
      )
    ])
    error_message = "query_folders must set exactly one of area, parent_id, or parent_key."
  }

  validation {
    condition = alltrue([
      for folder in var.query_folders : (
        folder.parent_key == null ||
        contains([
          for candidate in var.query_folders : coalesce(candidate.key, candidate.name)
          if candidate.parent_key == null
        ], folder.parent_key)
      )
    ])
    error_message = "query_folders.parent_key must reference a top-level folder key (parent_key unset)."
  }

  validation {
    condition = length(distinct([
      for folder in var.query_folders : coalesce(folder.key, folder.name)
    ])) == length(var.query_folders)
    error_message = "query_folders entries must have unique keys (key/name)."
  }

  validation {
    condition = alltrue([
      for folder in var.query_folders : (
        folder.project_id != null ||
        (var.project_id != null && length(trimspace(var.project_id)) > 0)
      )
    ])
    error_message = "query_folders require project_id either on the folder or via the module default."
  }
}

# -----------------------------------------------------------------------------
# Queries
# -----------------------------------------------------------------------------

variable "queries" {
  description = "List of work item queries to manage."
  type = list(object({
    key        = optional(string)
    project_id = optional(string)
    name       = string
    wiql       = string
    area       = optional(string)
    parent_id  = optional(number)
    parent_key = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for query in var.queries : (
        (query.key == null || length(trimspace(query.key)) > 0) &&
        (query.project_id == null || length(trimspace(query.project_id)) > 0)
      )
    ])
    error_message = "queries.key and queries.project_id must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for query in var.queries : length(trimspace(query.name)) > 0
    ])
    error_message = "queries.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for query in var.queries : length(trimspace(query.wiql)) > 0
    ])
    error_message = "queries.wiql must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for query in var.queries : (
        query.area == null || length(trimspace(query.area)) > 0
      )
    ])
    error_message = "queries.area must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for query in var.queries : (
        query.parent_id == null || query.parent_id > 0
      )
    ])
    error_message = "queries.parent_id must be a positive number when provided."
  }

  validation {
    condition = alltrue([
      for query in var.queries : (
        query.parent_key == null || length(trimspace(query.parent_key)) > 0
      )
    ])
    error_message = "queries.parent_key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for query in var.queries : (
        length(compact([query.area, query.parent_key])) + (query.parent_id != null ? 1 : 0) == 1
      )
    ])
    error_message = "queries must set exactly one of area, parent_id, or parent_key."
  }

  validation {
    condition = alltrue([
      for query in var.queries : (
        query.parent_key == null ||
        contains([for folder in var.query_folders : coalesce(folder.key, folder.name)], query.parent_key)
      )
    ])
    error_message = "queries.parent_key must reference an existing folder key."
  }

  validation {
    condition = length(distinct([
      for query in var.queries : coalesce(query.key, query.name)
    ])) == length(var.queries)
    error_message = "queries entries must have unique keys (key/name)."
  }

  validation {
    condition = alltrue([
      for query in var.queries : (
        query.project_id != null ||
        (var.project_id != null && length(trimspace(var.project_id)) > 0)
      )
    ])
    error_message = "queries require project_id either on the query or via the module default."
  }
}

# -----------------------------------------------------------------------------
# Query Permissions
# -----------------------------------------------------------------------------

variable "query_permissions" {
  description = "List of query permissions to assign."
  type = list(object({
    key         = optional(string)
    project_id  = optional(string)
    path        = optional(string)
    query_key   = optional(string)
    folder_key  = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.query_permissions : (
        (perm.key == null || length(trimspace(perm.key)) > 0) &&
        (perm.project_id == null || length(trimspace(perm.project_id)) > 0) &&
        (perm.path == null || length(trimspace(perm.path)) > 0) &&
        (perm.query_key == null || length(trimspace(perm.query_key)) > 0) &&
        (perm.folder_key == null || length(trimspace(perm.folder_key)) > 0)
      )
    ])
    error_message = "query_permissions.key, project_id, path, query_key, and folder_key must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.query_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "query_permissions.principal must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for perm in var.query_permissions : (
        length(compact([perm.path, perm.query_key, perm.folder_key])) == 1
      )
    ])
    error_message = "query_permissions must set exactly one of path, query_key, or folder_key."
  }

  validation {
    condition = alltrue([
      for perm in var.query_permissions : (
        perm.query_key == null ||
        contains([for query in var.queries : coalesce(query.key, query.name)], perm.query_key)
      )
    ])
    error_message = "query_permissions.query_key must reference an existing query key."
  }

  validation {
    condition = alltrue([
      for perm in var.query_permissions : (
        perm.folder_key == null ||
        contains([for folder in var.query_folders : coalesce(folder.key, folder.name)], perm.folder_key)
      )
    ])
    error_message = "query_permissions.folder_key must reference an existing folder key."
  }

  validation {
    condition = length(distinct([
      for perm in var.query_permissions : coalesce(perm.key, perm.principal, perm.path, perm.query_key, perm.folder_key)
    ])) == length(var.query_permissions)
    error_message = "query_permissions entries must have unique keys (key/principal/path/query_key/folder_key)."
  }

  validation {
    condition = alltrue([
      for perm in var.query_permissions : (
        perm.project_id != null ||
        (var.project_id != null && length(trimspace(var.project_id)) > 0)
      )
    ])
    error_message = "query_permissions require project_id either on the entry or via the module default."
  }
}

# -----------------------------------------------------------------------------
# Area / Iteration / Tagging Permissions
# -----------------------------------------------------------------------------

variable "area_permissions" {
  description = "List of area permissions to assign."
  type = list(object({
    key         = optional(string)
    project_id  = optional(string)
    path        = string
    principal   = string
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.area_permissions : (
        (perm.key == null || length(trimspace(perm.key)) > 0) &&
        (perm.project_id == null || length(trimspace(perm.project_id)) > 0)
      )
    ])
    error_message = "area_permissions.key and area_permissions.project_id must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.area_permissions : length(trimspace(perm.path)) > 0
    ])
    error_message = "area_permissions.path must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for perm in var.area_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "area_permissions.principal must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for perm in var.area_permissions : coalesce(perm.key, perm.principal, perm.path)
    ])) == length(var.area_permissions)
    error_message = "area_permissions entries must have unique keys (key/principal/path)."
  }

  validation {
    condition = alltrue([
      for perm in var.area_permissions : (
        perm.project_id != null ||
        (var.project_id != null && length(trimspace(var.project_id)) > 0)
      )
    ])
    error_message = "area_permissions require project_id either on the entry or via the module default."
  }
}

variable "iteration_permissions" {
  description = "List of iteration permissions to assign."
  type = list(object({
    key         = optional(string)
    project_id  = optional(string)
    path        = string
    principal   = string
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.iteration_permissions : (
        (perm.key == null || length(trimspace(perm.key)) > 0) &&
        (perm.project_id == null || length(trimspace(perm.project_id)) > 0)
      )
    ])
    error_message = "iteration_permissions.key and iteration_permissions.project_id must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.iteration_permissions : length(trimspace(perm.path)) > 0
    ])
    error_message = "iteration_permissions.path must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for perm in var.iteration_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "iteration_permissions.principal must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for perm in var.iteration_permissions : coalesce(perm.key, perm.principal, perm.path)
    ])) == length(var.iteration_permissions)
    error_message = "iteration_permissions entries must have unique keys (key/principal/path)."
  }

  validation {
    condition = alltrue([
      for perm in var.iteration_permissions : (
        perm.project_id != null ||
        (var.project_id != null && length(trimspace(var.project_id)) > 0)
      )
    ])
    error_message = "iteration_permissions require project_id either on the entry or via the module default."
  }
}

variable "tagging_permissions" {
  description = "List of tagging permissions to assign."
  type = list(object({
    key         = optional(string)
    project_id  = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.tagging_permissions : (
        (perm.key == null || length(trimspace(perm.key)) > 0) &&
        (perm.project_id == null || length(trimspace(perm.project_id)) > 0)
      )
    ])
    error_message = "tagging_permissions.key and tagging_permissions.project_id must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.tagging_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "tagging_permissions.principal must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for perm in var.tagging_permissions : coalesce(perm.key, perm.principal)
    ])) == length(var.tagging_permissions)
    error_message = "tagging_permissions entries must have unique keys (key/principal)."
  }

  validation {
    condition = alltrue([
      for perm in var.tagging_permissions : (
        perm.project_id != null ||
        (var.project_id != null && length(trimspace(var.project_id)) > 0)
      )
    ])
    error_message = "tagging_permissions require project_id either on the entry or via the module default."
  }
}
