locals {
  feed_ids = { for key, feed in azuredevops_feed.feed : key => feed.id }
  feed_permissions = {
    for idx, permission in var.feed_permissions : idx => permission
  }
  feed_retention_policies = {
    for idx, policy in var.feed_retention_policies : idx => policy
  }
}

resource "azuredevops_feed" "feed" {
  for_each = var.feeds

  name       = coalesce(each.value.name, each.key)
  project_id = try(each.value.project_id, null)

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
  role                = each.value.role
  project_id          = try(each.value.project_id, null)
  display_name        = try(each.value.display_name, null)
}

resource "azuredevops_feed_retention_policy" "feed_retention_policy" {
  for_each = local.feed_retention_policies

  feed_id                                   = each.value.feed_id != null ? each.value.feed_id : local.feed_ids[each.value.feed_key]
  count_limit                               = each.value.count_limit
  days_to_keep_recently_downloaded_packages = each.value.days_to_keep_recently_downloaded_packages
  project_id                                = try(each.value.project_id, null)
}
