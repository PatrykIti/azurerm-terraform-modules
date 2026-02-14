# -----------------------------------------------------------------------------
# Work Item (primary resource)
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Azure DevOps project ID for the work item."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

variable "title" {
  description = "Title of the work item."
  type        = string

  validation {
    condition     = trimspace(var.title) != ""
    error_message = "title must be a non-empty string."
  }
}

variable "type" {
  description = "Work item type (for example, Issue or Task)."
  type        = string

  validation {
    condition     = trimspace(var.type) != ""
    error_message = "type must be a non-empty string."
  }
}

variable "state" {
  description = "State of the work item."
  type        = string
  default     = null

  validation {
    condition     = var.state == null || length(trimspace(var.state)) > 0
    error_message = "state must be a non-empty string when provided."
  }
}

variable "tags" {
  description = "Tags to associate with the work item."
  type        = list(string)
  default     = null

  validation {
    condition = var.tags == null || alltrue([
      for tag in var.tags : length(trimspace(tag)) > 0
    ])
    error_message = "tags entries must be non-empty strings when provided."
  }
}

variable "area_path" {
  description = "Area path for the work item."
  type        = string
  default     = null

  validation {
    condition     = var.area_path == null || length(trimspace(var.area_path)) > 0
    error_message = "area_path must be a non-empty string when provided."
  }
}

variable "iteration_path" {
  description = "Iteration path for the work item."
  type        = string
  default     = null

  validation {
    condition     = var.iteration_path == null || length(trimspace(var.iteration_path)) > 0
    error_message = "iteration_path must be a non-empty string when provided."
  }
}

variable "parent_id" {
  description = "Parent work item ID."
  type        = number
  default     = null

  validation {
    condition     = var.parent_id == null || var.parent_id > 0
    error_message = "parent_id must be a positive number when provided."
  }
}

variable "custom_fields" {
  description = "Custom fields to set on the work item."
  type        = map(string)
  default     = null

  validation {
    condition = var.custom_fields == null || alltrue([
      for key, value in var.custom_fields :
      length(trimspace(key)) > 0 && length(trimspace(value)) > 0
    ])
    error_message = "custom_fields keys and values must be non-empty strings when provided."
  }
}
