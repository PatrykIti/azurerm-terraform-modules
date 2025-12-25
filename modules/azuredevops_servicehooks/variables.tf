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
# Webhook Service Hooks (TFS)
# -----------------------------------------------------------------------------

variable "webhooks" {
  description = "List of webhook service hooks to manage."
  type = list(object({
    url                       = string
    accept_untrusted_certs    = optional(bool)
    basic_auth_username       = optional(string)
    basic_auth_password       = optional(string)
    http_headers              = optional(map(string))
    resource_details_to_send  = optional(string)
    messages_to_send          = optional(string)
    detailed_messages_to_send = optional(string)

    build_completed = optional(object({
      definition_name = optional(string)
      build_status    = optional(string)
    }))
    git_pull_request_commented = optional(object({
      repository_id = optional(string)
      branch        = optional(string)
    }))
    git_pull_request_created = optional(object({
      repository_id                   = optional(string)
      branch                          = optional(string)
      pull_request_created_by         = optional(string)
      pull_request_reviewers_contains = optional(string)
    }))
    git_pull_request_merge_attempted = optional(object({
      repository_id                   = optional(string)
      branch                          = optional(string)
      pull_request_created_by         = optional(string)
      pull_request_reviewers_contains = optional(string)
      merge_result                    = optional(string)
    }))
    git_pull_request_updated = optional(object({
      repository_id                   = optional(string)
      branch                          = optional(string)
      pull_request_created_by         = optional(string)
      pull_request_reviewers_contains = optional(string)
      notification_type               = optional(string)
    }))
    git_push = optional(object({
      repository_id = optional(string)
      branch        = optional(string)
      pushed_by     = optional(string)
    }))
    repository_created = optional(object({
      project_id = optional(string)
    }))
    repository_deleted = optional(object({
      repository_id = optional(string)
    }))
    repository_forked = optional(object({
      repository_id = optional(string)
    }))
    repository_renamed = optional(object({
      repository_id = optional(string)
    }))
    repository_status_changed = optional(object({
      repository_id = optional(string)
    }))
    service_connection_created = optional(object({
      project_id = optional(string)
    }))
    service_connection_updated = optional(object({
      project_id = optional(string)
    }))
    tfvc_checkin = optional(object({
      path = string
    }))
    work_item_commented = optional(object({
      work_item_type  = optional(string)
      area_path       = optional(string)
      tag             = optional(string)
      comment_pattern = optional(string)
    }))
    work_item_created = optional(object({
      work_item_type = optional(string)
      area_path      = optional(string)
      tag            = optional(string)
    }))
    work_item_deleted = optional(object({
      work_item_type = optional(string)
      area_path      = optional(string)
      tag            = optional(string)
    }))
    work_item_restored = optional(object({
      work_item_type = optional(string)
      area_path      = optional(string)
      tag            = optional(string)
    }))
    work_item_updated = optional(object({
      work_item_type = optional(string)
      area_path      = optional(string)
      tag            = optional(string)
      changed_fields = optional(string)
      links_changed  = optional(bool)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for hook in var.webhooks : length(trimspace(hook.url)) > 0
    ])
    error_message = "webhooks.url must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for hook in var.webhooks : length(compact([
        hook.build_completed == null ? null : "build_completed",
        hook.git_pull_request_commented == null ? null : "git_pull_request_commented",
        hook.git_pull_request_created == null ? null : "git_pull_request_created",
        hook.git_pull_request_merge_attempted == null ? null : "git_pull_request_merge_attempted",
        hook.git_pull_request_updated == null ? null : "git_pull_request_updated",
        hook.git_push == null ? null : "git_push",
        hook.repository_created == null ? null : "repository_created",
        hook.repository_deleted == null ? null : "repository_deleted",
        hook.repository_forked == null ? null : "repository_forked",
        hook.repository_renamed == null ? null : "repository_renamed",
        hook.repository_status_changed == null ? null : "repository_status_changed",
        hook.service_connection_created == null ? null : "service_connection_created",
        hook.service_connection_updated == null ? null : "service_connection_updated",
        hook.tfvc_checkin == null ? null : "tfvc_checkin",
        hook.work_item_commented == null ? null : "work_item_commented",
        hook.work_item_created == null ? null : "work_item_created",
        hook.work_item_deleted == null ? null : "work_item_deleted",
        hook.work_item_restored == null ? null : "work_item_restored",
        hook.work_item_updated == null ? null : "work_item_updated",
      ])) == 1
    ])
    error_message = "webhooks must set exactly one event block."
  }
}

# -----------------------------------------------------------------------------
# Storage Queue Pipelines Hooks
# -----------------------------------------------------------------------------

variable "storage_queue_hooks" {
  description = "List of storage queue pipeline hooks to manage."
  type = list(object({
    account_name = string
    account_key  = string
    queue_name   = string
    ttl          = optional(number)
    visi_timeout = optional(number)
    run_state_changed_event = optional(object({
      pipeline_id       = optional(string)
      run_result_filter = optional(string)
      run_state_filter  = optional(string)
    }))
    stage_state_changed_event = optional(object({
      pipeline_id         = optional(string)
      stage_name          = optional(string)
      stage_result_filter = optional(string)
      stage_state_filter  = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for hook in var.storage_queue_hooks : (
        length(trimspace(hook.account_name)) > 0 &&
        length(trimspace(hook.account_key)) > 0 &&
        length(trimspace(hook.queue_name)) > 0
      )
    ])
    error_message = "storage_queue_hooks require account_name, account_key, and queue_name."
  }

  validation {
    condition = alltrue([
      for hook in var.storage_queue_hooks : (
        (hook.run_state_changed_event == null) != (hook.stage_state_changed_event == null)
      )
    ])
    error_message = "storage_queue_hooks must set exactly one of run_state_changed_event or stage_state_changed_event."
  }
}

# -----------------------------------------------------------------------------
# Service Hook Permissions
# -----------------------------------------------------------------------------

variable "servicehook_permissions" {
  description = "List of service hook permissions to assign."
  type = list(object({
    principal   = string
    permissions = map(string)
    replace     = optional(bool)
    project_id  = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.servicehook_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "servicehook_permissions.principal must be a non-empty string."
  }
}
