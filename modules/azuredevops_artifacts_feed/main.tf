locals {
  feed_ids         = { for key, feed in azuredevops_feed.feed : key => feed.id }
  feed_project_ids = { for key, feed in azuredevops_feed.feed : key => feed.project_id }
  feed_permissions = {
    for permission in var.feed_permissions :
    coalesce(permission.key, permission.feed_key, permission.feed_id, permission.identity_descriptor) => permission
  }
  feed_retention_policies = {
    for policy in var.feed_retention_policies :
    coalesce(policy.key, policy.feed_key, policy.feed_id) => policy
  }
}

resource "azuredevops_feed" "feed" {
  for_each = var.feeds

  name        = coalesce(each.value.name, each.key)
  project_id  = try(each.value.project_id, null)

  dynamic "features" {
    for_each = each.value.features != null ? [each.value.features] : []
    content {
      permanent_delete = try(features.value.permanent_delete, null)
      restore          = try(features.value.restore, null)
    }
  }
}

resource "azuredevops_feed_permission" "feed_permission" {
  for_each = local.feed_permissions

  feed_id             = each.value.feed_id != null ? each.value.feed_id : local.feed_ids[each.value.feed_key]
  identity_descriptor = each.value.identity_descriptor
  role                = lower(each.value.role)
  project_id = each.value.project_id != null ? each.value.project_id : (
    each.value.feed_key != null ? try(local.feed_project_ids[each.value.feed_key], null) : null
  )
  display_name        = try(each.value.display_name, null)
}

resource "azuredevops_feed_retention_policy" "feed_retention_policy" {
  for_each = local.feed_retention_policies

  feed_id                                   = each.value.feed_id != null ? each.value.feed_id : local.feed_ids[each.value.feed_key]
  count_limit                               = each.value.count_limit
  days_to_keep_recently_downloaded_packages = each.value.days_to_keep_recently_downloaded_packages
  project_id = each.value.project_id != null ? each.value.project_id : (
    each.value.feed_key != null ? try(local.feed_project_ids[each.value.feed_key], null) : null
  )
}
