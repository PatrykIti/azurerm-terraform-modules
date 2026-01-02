locals {
  # Normalize list inputs into stable maps for for_each addressing.
  feed_permissions = {
    for feed_permission in var.feed_permissions :
    coalesce(feed_permission.key, feed_permission.identity_descriptor) => feed_permission
  }
  # Ensure retention policy resources keep stable addresses across reorders.
  feed_retention_policies = {
    for retention_policy in var.feed_retention_policies :
    coalesce(
      retention_policy.key,
      format(
        "%s-%s",
        retention_policy.count_limit,
        retention_policy.days_to_keep_recently_downloaded_packages
      )
    ) => retention_policy
  }
}

resource "azuredevops_feed" "feed" {
  name        = var.name
  project_id  = var.project_id
  description = var.description

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

  feed_id             = azuredevops_feed.feed.id
  identity_descriptor = each.value.identity_descriptor
  role                = lower(each.value.role)
  project_id          = var.project_id
  display_name        = try(each.value.display_name, null)
}

resource "azuredevops_feed_retention_policy" "feed_retention_policy" {
  for_each = local.feed_retention_policies

  feed_id                                   = azuredevops_feed.feed.id
  count_limit                               = each.value.count_limit
  days_to_keep_recently_downloaded_packages = each.value.days_to_keep_recently_downloaded_packages
  project_id                                = var.project_id
}
