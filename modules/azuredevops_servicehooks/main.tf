locals {
  webhooks                = { for idx, hook in var.webhooks : idx => hook }
  storage_queue_hooks     = { for idx, hook in var.storage_queue_hooks : idx => hook }
  servicehook_permissions = { for idx, perm in var.servicehook_permissions : idx => perm }
}

resource "azuredevops_servicehook_webhook_tfs" "webhook" {
  for_each = local.webhooks

  project_id                = var.project_id
  url                       = each.value.url
  accept_untrusted_certs    = try(each.value.accept_untrusted_certs, null)
  basic_auth_username       = try(each.value.basic_auth_username, null)
  basic_auth_password       = try(each.value.basic_auth_password, null)
  http_headers              = try(each.value.http_headers, null)
  resource_details_to_send  = try(each.value.resource_details_to_send, null)
  messages_to_send          = try(each.value.messages_to_send, null)
  detailed_messages_to_send = try(each.value.detailed_messages_to_send, null)

  dynamic "build_completed" {
    for_each = each.value.build_completed != null ? [each.value.build_completed] : []
    content {
      definition_name = try(build_completed.value.definition_name, null)
      build_status    = try(build_completed.value.build_status, null)
    }
  }

  dynamic "git_pull_request_commented" {
    for_each = each.value.git_pull_request_commented != null ? [each.value.git_pull_request_commented] : []
    content {
      repository_id = try(git_pull_request_commented.value.repository_id, null)
      branch        = try(git_pull_request_commented.value.branch, null)
    }
  }

  dynamic "git_pull_request_created" {
    for_each = each.value.git_pull_request_created != null ? [each.value.git_pull_request_created] : []
    content {
      repository_id                   = try(git_pull_request_created.value.repository_id, null)
      branch                          = try(git_pull_request_created.value.branch, null)
      pull_request_created_by         = try(git_pull_request_created.value.pull_request_created_by, null)
      pull_request_reviewers_contains = try(git_pull_request_created.value.pull_request_reviewers_contains, null)
    }
  }

  dynamic "git_pull_request_merge_attempted" {
    for_each = each.value.git_pull_request_merge_attempted != null ? [each.value.git_pull_request_merge_attempted] : []
    content {
      repository_id                   = try(git_pull_request_merge_attempted.value.repository_id, null)
      branch                          = try(git_pull_request_merge_attempted.value.branch, null)
      pull_request_created_by         = try(git_pull_request_merge_attempted.value.pull_request_created_by, null)
      pull_request_reviewers_contains = try(git_pull_request_merge_attempted.value.pull_request_reviewers_contains, null)
      merge_result                    = try(git_pull_request_merge_attempted.value.merge_result, null)
    }
  }

  dynamic "git_pull_request_updated" {
    for_each = each.value.git_pull_request_updated != null ? [each.value.git_pull_request_updated] : []
    content {
      repository_id                   = try(git_pull_request_updated.value.repository_id, null)
      branch                          = try(git_pull_request_updated.value.branch, null)
      pull_request_created_by         = try(git_pull_request_updated.value.pull_request_created_by, null)
      pull_request_reviewers_contains = try(git_pull_request_updated.value.pull_request_reviewers_contains, null)
      notification_type               = try(git_pull_request_updated.value.notification_type, null)
    }
  }

  dynamic "git_push" {
    for_each = each.value.git_push != null ? [each.value.git_push] : []
    content {
      repository_id = try(git_push.value.repository_id, null)
      branch        = try(git_push.value.branch, null)
      pushed_by     = try(git_push.value.pushed_by, null)
    }
  }

  dynamic "repository_created" {
    for_each = each.value.repository_created != null ? [each.value.repository_created] : []
    content {
      project_id = try(repository_created.value.project_id, null)
    }
  }

  dynamic "repository_deleted" {
    for_each = each.value.repository_deleted != null ? [each.value.repository_deleted] : []
    content {
      repository_id = try(repository_deleted.value.repository_id, null)
    }
  }

  dynamic "repository_forked" {
    for_each = each.value.repository_forked != null ? [each.value.repository_forked] : []
    content {
      repository_id = try(repository_forked.value.repository_id, null)
    }
  }

  dynamic "repository_renamed" {
    for_each = each.value.repository_renamed != null ? [each.value.repository_renamed] : []
    content {
      repository_id = try(repository_renamed.value.repository_id, null)
    }
  }

  dynamic "repository_status_changed" {
    for_each = each.value.repository_status_changed != null ? [each.value.repository_status_changed] : []
    content {
      repository_id = try(repository_status_changed.value.repository_id, null)
    }
  }

  dynamic "service_connection_created" {
    for_each = each.value.service_connection_created != null ? [each.value.service_connection_created] : []
    content {
      project_id = try(service_connection_created.value.project_id, null)
    }
  }

  dynamic "service_connection_updated" {
    for_each = each.value.service_connection_updated != null ? [each.value.service_connection_updated] : []
    content {
      project_id = try(service_connection_updated.value.project_id, null)
    }
  }

  dynamic "tfvc_checkin" {
    for_each = each.value.tfvc_checkin != null ? [each.value.tfvc_checkin] : []
    content {
      path = tfvc_checkin.value.path
    }
  }

  dynamic "work_item_commented" {
    for_each = each.value.work_item_commented != null ? [each.value.work_item_commented] : []
    content {
      work_item_type  = try(work_item_commented.value.work_item_type, null)
      area_path       = try(work_item_commented.value.area_path, null)
      tag             = try(work_item_commented.value.tag, null)
      comment_pattern = try(work_item_commented.value.comment_pattern, null)
    }
  }

  dynamic "work_item_created" {
    for_each = each.value.work_item_created != null ? [each.value.work_item_created] : []
    content {
      work_item_type = try(work_item_created.value.work_item_type, null)
      area_path      = try(work_item_created.value.area_path, null)
      tag            = try(work_item_created.value.tag, null)
    }
  }

  dynamic "work_item_deleted" {
    for_each = each.value.work_item_deleted != null ? [each.value.work_item_deleted] : []
    content {
      work_item_type = try(work_item_deleted.value.work_item_type, null)
      area_path      = try(work_item_deleted.value.area_path, null)
      tag            = try(work_item_deleted.value.tag, null)
    }
  }

  dynamic "work_item_restored" {
    for_each = each.value.work_item_restored != null ? [each.value.work_item_restored] : []
    content {
      work_item_type = try(work_item_restored.value.work_item_type, null)
      area_path      = try(work_item_restored.value.area_path, null)
      tag            = try(work_item_restored.value.tag, null)
    }
  }

  dynamic "work_item_updated" {
    for_each = each.value.work_item_updated != null ? [each.value.work_item_updated] : []
    content {
      work_item_type = try(work_item_updated.value.work_item_type, null)
      area_path      = try(work_item_updated.value.area_path, null)
      tag            = try(work_item_updated.value.tag, null)
      changed_fields = try(work_item_updated.value.changed_fields, null)
      links_changed  = try(work_item_updated.value.links_changed, null)
    }
  }
}

resource "azuredevops_servicehook_storage_queue_pipelines" "storage_queue" {
  for_each = local.storage_queue_hooks

  project_id   = var.project_id
  account_name = each.value.account_name
  account_key  = each.value.account_key
  queue_name   = each.value.queue_name
  ttl          = try(each.value.ttl, null)
  visi_timeout = try(each.value.visi_timeout, null)

  dynamic "run_state_changed_event" {
    for_each = each.value.run_state_changed_event != null ? [each.value.run_state_changed_event] : []
    content {
      pipeline_id       = try(run_state_changed_event.value.pipeline_id, null)
      run_result_filter = try(run_state_changed_event.value.run_result_filter, null)
      run_state_filter  = try(run_state_changed_event.value.run_state_filter, null)
    }
  }

  dynamic "stage_state_changed_event" {
    for_each = each.value.stage_state_changed_event != null ? [each.value.stage_state_changed_event] : []
    content {
      pipeline_id         = try(stage_state_changed_event.value.pipeline_id, null)
      stage_name          = try(stage_state_changed_event.value.stage_name, null)
      stage_result_filter = try(stage_state_changed_event.value.stage_result_filter, null)
      stage_state_filter  = try(stage_state_changed_event.value.stage_state_filter, null)
    }
  }
}

resource "azuredevops_servicehook_permissions" "servicehook_permissions" {
  for_each = local.servicehook_permissions

  project_id  = each.value.project_id != null ? each.value.project_id : var.project_id
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = try(each.value.replace, true)
}
