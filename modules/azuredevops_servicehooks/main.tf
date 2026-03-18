resource "azuredevops_servicehook_webhook_tfs" "webhook" {
  project_id                = var.project_id
  url                       = try(var.webhook.url, null)
  accept_untrusted_certs    = try(var.webhook.accept_untrusted_certs, null)
  basic_auth_username       = try(var.webhook.basic_auth_username, null)
  basic_auth_password       = try(sensitive(var.webhook.basic_auth_password), null)
  http_headers              = try(var.webhook.http_headers, null)
  resource_details_to_send  = try(var.webhook.resource_details_to_send, null)
  messages_to_send          = try(var.webhook.messages_to_send, null)
  detailed_messages_to_send = try(var.webhook.detailed_messages_to_send, null)

  dynamic "build_completed" {
    for_each = try(var.webhook.build_completed, null) == null ? [] : [var.webhook.build_completed]
    content {
      definition_name = try(build_completed.value.definition_name, null)
      build_status    = try(build_completed.value.build_status, null)
    }
  }

  dynamic "git_pull_request_commented" {
    for_each = try(var.webhook.git_pull_request_commented, null) == null ? [] : [var.webhook.git_pull_request_commented]
    content {
      repository_id = try(git_pull_request_commented.value.repository_id, null)
      branch        = try(git_pull_request_commented.value.branch, null)
    }
  }

  dynamic "git_pull_request_created" {
    for_each = try(var.webhook.git_pull_request_created, null) == null ? [] : [var.webhook.git_pull_request_created]
    content {
      repository_id                   = try(git_pull_request_created.value.repository_id, null)
      branch                          = try(git_pull_request_created.value.branch, null)
      pull_request_created_by         = try(git_pull_request_created.value.pull_request_created_by, null)
      pull_request_reviewers_contains = try(git_pull_request_created.value.pull_request_reviewers_contains, null)
    }
  }

  dynamic "git_pull_request_merge_attempted" {
    for_each = try(var.webhook.git_pull_request_merge_attempted, null) == null ? [] : [var.webhook.git_pull_request_merge_attempted]
    content {
      repository_id                   = try(git_pull_request_merge_attempted.value.repository_id, null)
      branch                          = try(git_pull_request_merge_attempted.value.branch, null)
      pull_request_created_by         = try(git_pull_request_merge_attempted.value.pull_request_created_by, null)
      pull_request_reviewers_contains = try(git_pull_request_merge_attempted.value.pull_request_reviewers_contains, null)
      merge_result                    = try(git_pull_request_merge_attempted.value.merge_result, null)
    }
  }

  dynamic "git_pull_request_updated" {
    for_each = try(var.webhook.git_pull_request_updated, null) == null ? [] : [var.webhook.git_pull_request_updated]
    content {
      repository_id                   = try(git_pull_request_updated.value.repository_id, null)
      branch                          = try(git_pull_request_updated.value.branch, null)
      pull_request_created_by         = try(git_pull_request_updated.value.pull_request_created_by, null)
      pull_request_reviewers_contains = try(git_pull_request_updated.value.pull_request_reviewers_contains, null)
      notification_type               = try(git_pull_request_updated.value.notification_type, null)
    }
  }

  dynamic "git_push" {
    for_each = try(var.webhook.git_push, null) == null ? [] : [var.webhook.git_push]
    content {
      repository_id = try(git_push.value.repository_id, null)
      branch        = try(git_push.value.branch, null)
      pushed_by     = try(git_push.value.pushed_by, null)
    }
  }

  dynamic "repository_created" {
    for_each = try(var.webhook.repository_created, null) == null ? [] : [var.webhook.repository_created]
    content {
      project_id = try(repository_created.value.project_id, null)
    }
  }

  dynamic "repository_deleted" {
    for_each = try(var.webhook.repository_deleted, null) == null ? [] : [var.webhook.repository_deleted]
    content {
      repository_id = try(repository_deleted.value.repository_id, null)
    }
  }

  dynamic "repository_forked" {
    for_each = try(var.webhook.repository_forked, null) == null ? [] : [var.webhook.repository_forked]
    content {
      repository_id = try(repository_forked.value.repository_id, null)
    }
  }

  dynamic "repository_renamed" {
    for_each = try(var.webhook.repository_renamed, null) == null ? [] : [var.webhook.repository_renamed]
    content {
      repository_id = try(repository_renamed.value.repository_id, null)
    }
  }

  dynamic "repository_status_changed" {
    for_each = try(var.webhook.repository_status_changed, null) == null ? [] : [var.webhook.repository_status_changed]
    content {
      repository_id = try(repository_status_changed.value.repository_id, null)
    }
  }

  dynamic "service_connection_created" {
    for_each = try(var.webhook.service_connection_created, null) == null ? [] : [var.webhook.service_connection_created]
    content {
      project_id = try(service_connection_created.value.project_id, null)
    }
  }

  dynamic "service_connection_updated" {
    for_each = try(var.webhook.service_connection_updated, null) == null ? [] : [var.webhook.service_connection_updated]
    content {
      project_id = try(service_connection_updated.value.project_id, null)
    }
  }

  dynamic "tfvc_checkin" {
    for_each = try(var.webhook.tfvc_checkin, null) == null ? [] : [var.webhook.tfvc_checkin]
    content {
      path = tfvc_checkin.value.path
    }
  }

  dynamic "work_item_commented" {
    for_each = try(var.webhook.work_item_commented, null) == null ? [] : [var.webhook.work_item_commented]
    content {
      work_item_type  = try(work_item_commented.value.work_item_type, null)
      area_path       = try(work_item_commented.value.area_path, null)
      tag             = try(work_item_commented.value.tag, null)
      comment_pattern = try(work_item_commented.value.comment_pattern, null)
    }
  }

  dynamic "work_item_created" {
    for_each = try(var.webhook.work_item_created, null) == null ? [] : [var.webhook.work_item_created]
    content {
      work_item_type = try(work_item_created.value.work_item_type, null)
      area_path      = try(work_item_created.value.area_path, null)
      tag            = try(work_item_created.value.tag, null)
    }
  }

  dynamic "work_item_deleted" {
    for_each = try(var.webhook.work_item_deleted, null) == null ? [] : [var.webhook.work_item_deleted]
    content {
      work_item_type = try(work_item_deleted.value.work_item_type, null)
      area_path      = try(work_item_deleted.value.area_path, null)
      tag            = try(work_item_deleted.value.tag, null)
    }
  }

  dynamic "work_item_restored" {
    for_each = try(var.webhook.work_item_restored, null) == null ? [] : [var.webhook.work_item_restored]
    content {
      work_item_type = try(work_item_restored.value.work_item_type, null)
      area_path      = try(work_item_restored.value.area_path, null)
      tag            = try(work_item_restored.value.tag, null)
    }
  }

  dynamic "work_item_updated" {
    for_each = try(var.webhook.work_item_updated, null) == null ? [] : [var.webhook.work_item_updated]
    content {
      work_item_type = try(work_item_updated.value.work_item_type, null)
      area_path      = try(work_item_updated.value.area_path, null)
      tag            = try(work_item_updated.value.tag, null)
      changed_fields = try(work_item_updated.value.changed_fields, null)
      links_changed  = try(work_item_updated.value.links_changed, null)
    }
  }
}
