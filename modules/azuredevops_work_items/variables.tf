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
        process.name == null || length(trimspace(process.name)) > 0
      )
    ])
    error_message = "processes.name must be a non-empty string when provided."
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
  description = "List of work items to manage."
  type = list(object({
    project_id     = optional(string)
    title          = string
    type           = string
    state          = optional(string)
    tags           = optional(list(string))
    area_path      = optional(string)
    iteration_path = optional(string)
    parent_id      = optional(string)
    custom_fields  = optional(map(string))
  }))
  default = []

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
}

# -----------------------------------------------------------------------------
# Query Folders
# -----------------------------------------------------------------------------

variable "query_folders" {
  description = "List of work item query folders to manage."
  type = list(object({
    project_id = optional(string)
    name       = string
    area       = optional(string)
    parent_id  = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for folder in var.query_folders : length(trimspace(folder.name)) > 0
    ])
    error_message = "query_folders.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for folder in var.query_folders : (
        (folder.area != null) != (folder.parent_id != null)
      )
    ])
    error_message = "query_folders must set exactly one of area or parent_id."
  }
}

# -----------------------------------------------------------------------------
# Queries
# -----------------------------------------------------------------------------

variable "queries" {
  description = "List of work item queries to manage."
  type = list(object({
    project_id = optional(string)
    name       = string
    wiql       = string
    area       = optional(string)
    parent_id  = optional(string)
  }))
  default = []

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
        (query.area != null) != (query.parent_id != null)
      )
    ])
    error_message = "queries must set exactly one of area or parent_id."
  }
}

# -----------------------------------------------------------------------------
# Query Permissions
# -----------------------------------------------------------------------------

variable "query_permissions" {
  description = "List of query permissions to assign."
  type = list(object({
    project_id  = optional(string)
    path        = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.query_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "query_permissions.principal must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Area / Iteration / Tagging Permissions
# -----------------------------------------------------------------------------

variable "area_permissions" {
  description = "List of area permissions to assign."
  type = list(object({
    project_id  = optional(string)
    path        = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.area_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "area_permissions.principal must be a non-empty string."
  }
}

variable "iteration_permissions" {
  description = "List of iteration permissions to assign."
  type = list(object({
    project_id  = optional(string)
    path        = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.iteration_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "iteration_permissions.principal must be a non-empty string."
  }
}

variable "tagging_permissions" {
  description = "List of tagging permissions to assign."
  type = list(object({
    project_id  = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.tagging_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "tagging_permissions.principal must be a non-empty string."
  }
}
