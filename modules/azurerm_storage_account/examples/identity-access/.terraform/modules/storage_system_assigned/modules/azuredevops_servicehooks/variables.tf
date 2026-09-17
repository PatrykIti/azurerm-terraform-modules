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

variable "webhook" {
  description = "Webhook service hook configuration. Includes sensitive fields like basic_auth_password."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.webhook == null || (
      length(trimspace(var.webhook.url)) > 0 &&
      (var.webhook.basic_auth_username == null || length(trimspace(var.webhook.basic_auth_username)) > 0) &&
      (var.webhook.basic_auth_password == null || length(trimspace(var.webhook.basic_auth_password)) > 0)
    )
    error_message = "webhook.url must be non-empty; basic_auth_username/basic_auth_password must be non-empty when provided."
  }

  validation {
    condition = var.webhook == null || length(compact([
      var.webhook.build_completed == null ? null : "build_completed",
      var.webhook.git_pull_request_commented == null ? null : "git_pull_request_commented",
      var.webhook.git_pull_request_created == null ? null : "git_pull_request_created",
      var.webhook.git_pull_request_merge_attempted == null ? null : "git_pull_request_merge_attempted",
      var.webhook.git_pull_request_updated == null ? null : "git_pull_request_updated",
      var.webhook.git_push == null ? null : "git_push",
      var.webhook.repository_created == null ? null : "repository_created",
      var.webhook.repository_deleted == null ? null : "repository_deleted",
      var.webhook.repository_forked == null ? null : "repository_forked",
      var.webhook.repository_renamed == null ? null : "repository_renamed",
      var.webhook.repository_status_changed == null ? null : "repository_status_changed",
      var.webhook.service_connection_created == null ? null : "service_connection_created",
      var.webhook.service_connection_updated == null ? null : "service_connection_updated",
      var.webhook.tfvc_checkin == null ? null : "tfvc_checkin",
      var.webhook.work_item_commented == null ? null : "work_item_commented",
      var.webhook.work_item_created == null ? null : "work_item_created",
      var.webhook.work_item_deleted == null ? null : "work_item_deleted",
      var.webhook.work_item_restored == null ? null : "work_item_restored",
      var.webhook.work_item_updated == null ? null : "work_item_updated",
    ])) == 1
    error_message = "webhook must set exactly one event block."
  }

  validation {
    condition     = var.webhook == null || var.webhook.tfvc_checkin == null || length(trimspace(var.webhook.tfvc_checkin.path)) > 0
    error_message = "webhook.tfvc_checkin.path must be a non-empty string."
  }

  validation {
    condition = var.webhook == null || var.webhook.resource_details_to_send == null || contains([
      "all",
      "minimal",
      "none",
    ], lower(var.webhook.resource_details_to_send))
    error_message = "webhook.resource_details_to_send must be one of: all, minimal, none."
  }

  validation {
    condition = var.webhook == null || var.webhook.messages_to_send == null || contains([
      "all",
      "text",
      "html",
      "markdown",
      "none",
    ], lower(var.webhook.messages_to_send))
    error_message = "webhook.messages_to_send must be one of: all, text, html, markdown, none."
  }

  validation {
    condition = var.webhook == null || var.webhook.detailed_messages_to_send == null || contains([
      "all",
      "text",
      "html",
      "markdown",
      "none",
    ], lower(var.webhook.detailed_messages_to_send))
    error_message = "webhook.detailed_messages_to_send must be one of: all, text, html, markdown, none."
  }
}

# -----------------------------------------------------------------------------
# Storage Queue Pipelines Hooks
# -----------------------------------------------------------------------------

variable "storage_queue_hook" {
  description = "Storage queue pipeline hook configuration. Includes sensitive fields like account_key."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.storage_queue_hook == null || (
      length(trimspace(var.storage_queue_hook.account_name)) > 0 &&
      length(trimspace(var.storage_queue_hook.account_key)) > 0 &&
      length(trimspace(var.storage_queue_hook.queue_name)) > 0
    )
    error_message = "storage_queue_hook requires account_name, account_key, and queue_name."
  }

  validation {
    condition = var.storage_queue_hook == null || (
      (var.storage_queue_hook.run_state_changed_event == null) != (var.storage_queue_hook.stage_state_changed_event == null)
    )
    error_message = "storage_queue_hook must set exactly one of run_state_changed_event or stage_state_changed_event."
  }

  validation {
    condition     = var.storage_queue_hook == null || var.storage_queue_hook.ttl == null || var.storage_queue_hook.ttl >= 0
    error_message = "storage_queue_hook.ttl must be 0 or greater when provided."
  }

  validation {
    condition     = var.storage_queue_hook == null || var.storage_queue_hook.visi_timeout == null || var.storage_queue_hook.visi_timeout >= 0
    error_message = "storage_queue_hook.visi_timeout must be 0 or greater when provided."
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
    replace     = optional(bool, true)
    project_id  = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.servicehook_permissions : (
        length(trimspace(permission.principal)) > 0 &&
        (permission.key == null || length(trimspace(permission.key)) > 0) &&
        (permission.project_id == null || length(trimspace(permission.project_id)) > 0)
      )
    ])
    error_message = "servicehook_permissions.principal must be non-empty; key/project_id must be non-empty when provided."
  }

  validation {
    condition = alltrue([
      for permission in var.servicehook_permissions : length(permission.permissions) > 0
    ])
    error_message = "servicehook_permissions.permissions must be a non-empty map."
  }

  validation {
    condition = alltrue([
      for permission in var.servicehook_permissions : alltrue([
        for status in values(permission.permissions) : contains(["allow", "deny", "notset"], lower(status))
      ])
    ])
    error_message = "servicehook_permissions.permissions values must be one of: Allow, Deny, NotSet."
  }

  validation {
    condition = length(distinct([
      for permission in var.servicehook_permissions : coalesce(permission.key, permission.principal)
    ])) == length(var.servicehook_permissions)
    error_message = "servicehook_permissions keys must be unique; set key when principal would collide."
  }
}
