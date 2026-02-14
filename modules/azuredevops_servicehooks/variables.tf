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
# Webhook Service Hook (TFS)
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
  sensitive = true

  validation {
    condition = (
      length(trimspace(var.webhook.url)) > 0 &&
      (var.webhook.basic_auth_username == null || length(trimspace(var.webhook.basic_auth_username)) > 0) &&
      (var.webhook.basic_auth_password == null || length(trimspace(var.webhook.basic_auth_password)) > 0)
    )
    error_message = "webhook.url must be non-empty; basic_auth_username/basic_auth_password must be non-empty when provided."
  }

  validation {
    condition = length(compact([
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
    condition     = var.webhook.tfvc_checkin == null || length(trimspace(var.webhook.tfvc_checkin.path)) > 0
    error_message = "webhook.tfvc_checkin.path must be a non-empty string."
  }

  validation {
    condition = var.webhook.resource_details_to_send == null || contains([
      "all",
      "minimal",
      "none",
    ], lower(var.webhook.resource_details_to_send))
    error_message = "webhook.resource_details_to_send must be one of: all, minimal, none."
  }

  validation {
    condition = var.webhook.messages_to_send == null || contains([
      "all",
      "text",
      "html",
      "markdown",
      "none",
    ], lower(var.webhook.messages_to_send))
    error_message = "webhook.messages_to_send must be one of: all, text, html, markdown, none."
  }

  validation {
    condition = var.webhook.detailed_messages_to_send == null || contains([
      "all",
      "text",
      "html",
      "markdown",
      "none",
    ], lower(var.webhook.detailed_messages_to_send))
    error_message = "webhook.detailed_messages_to_send must be one of: all, text, html, markdown, none."
  }
}
