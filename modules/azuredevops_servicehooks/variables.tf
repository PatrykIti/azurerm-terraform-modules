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
  description = "List of webhook service hooks to manage. Includes sensitive fields like basic_auth_password."
  type = list(object({
    key                       = optional(string)
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
      for hook in var.webhooks : (
        length(trimspace(hook.url)) > 0 &&
        (hook.key == null || length(trimspace(hook.key)) > 0) &&
        (hook.basic_auth_username == null || length(trimspace(hook.basic_auth_username)) > 0) &&
        (hook.basic_auth_password == null || length(trimspace(hook.basic_auth_password)) > 0)
      )
    ])
    error_message = "webhooks.url must be non-empty; key/basic_auth_username/basic_auth_password must be non-empty when provided."
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

  validation {
    condition = alltrue([
      for hook in var.webhooks : (
        hook.tfvc_checkin == null || length(trimspace(hook.tfvc_checkin.path)) > 0
      )
    ])
    error_message = "webhooks.tfvc_checkin.path must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for hook in var.webhooks : (
        hook.resource_details_to_send == null ||
        contains(["all", "minimal", "none"], lower(hook.resource_details_to_send))
      )
    ])
    error_message = "webhooks.resource_details_to_send must be one of: all, minimal, none."
  }

  validation {
    condition = alltrue([
      for hook in var.webhooks : (
        hook.messages_to_send == null ||
        contains(["all", "text", "html", "markdown", "none"], lower(hook.messages_to_send))
      )
    ])
    error_message = "webhooks.messages_to_send must be one of: all, text, html, markdown, none."
  }

  validation {
    condition = alltrue([
      for hook in var.webhooks : (
        hook.detailed_messages_to_send == null ||
        contains(["all", "text", "html", "markdown", "none"], lower(hook.detailed_messages_to_send))
      )
    ])
    error_message = "webhooks.detailed_messages_to_send must be one of: all, text, html, markdown, none."
  }

  validation {
    condition = length(distinct([
      for hook in var.webhooks : coalesce(
        hook.key,
        format("%s:%s", join(",", compact([
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
        ])), hook.url)
      )
    ])) == length(var.webhooks)
    error_message = "webhooks keys must be unique; set key when event type and url would collide."
  }
}

# -----------------------------------------------------------------------------
# Storage Queue Pipelines Hooks
# -----------------------------------------------------------------------------

variable "storage_queue_hooks" {
  description = "List of storage queue pipeline hooks to manage. Includes sensitive fields like account_key."
  type = list(object({
    key          = optional(string)
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
        length(trimspace(hook.queue_name)) > 0 &&
        (hook.key == null || length(trimspace(hook.key)) > 0)
      )
    ])
    error_message = "storage_queue_hooks require account_name, account_key, and queue_name; key must be non-empty when provided."
  }

  validation {
    condition = alltrue([
      for hook in var.storage_queue_hooks : (
        (hook.run_state_changed_event == null) != (hook.stage_state_changed_event == null)
      )
    ])
    error_message = "storage_queue_hooks must set exactly one of run_state_changed_event or stage_state_changed_event."
  }

  validation {
    condition = alltrue([
      for hook in var.storage_queue_hooks : (
        hook.ttl == null || hook.ttl >= 0
      )
    ])
    error_message = "storage_queue_hooks.ttl must be 0 or greater when provided."
  }

  validation {
    condition = alltrue([
      for hook in var.storage_queue_hooks : (
        hook.visi_timeout == null || hook.visi_timeout >= 0
      )
    ])
    error_message = "storage_queue_hooks.visi_timeout must be 0 or greater when provided."
  }

  validation {
    condition = length(distinct([
      for hook in var.storage_queue_hooks : coalesce(
        hook.key,
        format("%s:%s", hook.queue_name, join(",", compact([
          hook.run_state_changed_event == null ? null : "run_state_changed_event",
          hook.stage_state_changed_event == null ? null : "stage_state_changed_event",
        ])))
      )
    ])) == length(var.storage_queue_hooks)
    error_message = "storage_queue_hooks keys must be unique; set key when queue_name and event would collide."
  }
}

# -----------------------------------------------------------------------------
# Service Hook Permissions
# -----------------------------------------------------------------------------

variable "servicehook_permissions" {
  description = "List of service hook permissions to assign."
  type = list(object({
    key         = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool)
    project_id  = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.servicehook_permissions : (
        length(trimspace(perm.principal)) > 0 &&
        (perm.key == null || length(trimspace(perm.key)) > 0) &&
        (perm.project_id == null || length(trimspace(perm.project_id)) > 0)
      )
    ])
    error_message = "servicehook_permissions.principal must be non-empty; key/project_id must be non-empty when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.servicehook_permissions : length(perm.permissions) > 0
    ])
    error_message = "servicehook_permissions.permissions must be a non-empty map."
  }

  validation {
    condition = alltrue([
      for perm in var.servicehook_permissions : alltrue([
        for status in values(perm.permissions) : contains(["allow", "deny", "notset"], lower(status))
      ])
    ])
    error_message = "servicehook_permissions.permissions values must be one of: Allow, Deny, NotSet."
  }

  validation {
    condition = length(distinct([
      for perm in var.servicehook_permissions : coalesce(
        perm.key,
        format("%s:%s", coalesce(perm.project_id, var.project_id), perm.principal)
      )
    ])) == length(var.servicehook_permissions)
    error_message = "servicehook_permissions keys must be unique; set key when project_id and principal would collide."
  }
}
