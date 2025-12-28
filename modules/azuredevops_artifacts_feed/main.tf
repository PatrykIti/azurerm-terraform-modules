locals {
  create_feed = var.name != null && var.project_id != null
  feed_id     = local.create_feed ? azuredevops_feed.feed[0].id : null
  feed_permissions = {
    for permission in var.feed_permissions :
    coalesce(permission.key, permission.identity_descriptor) => permission
  }
  feed_retention_policies = {
    for policy in var.feed_retention_policies :
    coalesce(
      policy.key,
      format(
        "%s-%s",
        policy.count_limit,
        policy.days_to_keep_recently_downloaded_packages
      )
    ) => policy
  }
}

resource "azuredevops_feed" "feed" {
  count = local.create_feed ? 1 : 0

  name       = var.name
  project_id = var.project_id

  dynamic "features" {
    for_each = var.features == null ? [] : [var.features]
    content {
      permanent_delete = try(features.value.permanent_delete, null)
      restore          = try(features.value.restore, null)
    }
  }
}

resource "azuredevops_feed_permission" "feed_permission" {
  for_each = local.feed_permissions

  feed_id             = each.value.feed_id != null ? each.value.feed_id : local.feed_id
  identity_descriptor = each.value.identity_descriptor
  role                = lower(each.value.role)
  project_id          = each.value.project_id != null ? each.value.project_id : (each.value.feed_id == null ? var.project_id : null)
  display_name        = try(each.value.display_name, null)

  lifecycle {
    precondition {
      condition     = each.value.feed_id != null || local.create_feed
      error_message = "feed_permissions requires feed_id when the module feed is not created."
    }
  }
}

resource "azuredevops_feed_retention_policy" "feed_retention_policy" {
  for_each = local.feed_retention_policies

  feed_id                                   = each.value.feed_id != null ? each.value.feed_id : local.feed_id
  count_limit                               = each.value.count_limit
  days_to_keep_recently_downloaded_packages = each.value.days_to_keep_recently_downloaded_packages
  project_id                                = each.value.project_id != null ? each.value.project_id : (each.value.feed_id == null ? var.project_id : null)

  lifecycle {
    precondition {
      condition     = each.value.feed_id != null || local.create_feed
      error_message = "feed_retention_policies requires feed_id when the module feed is not created."
    }
  }
}
