# Diagnostic settings for storage account and services

locals {
  diagnostic_scope_ids = {
    storage_account = azurerm_storage_account.storage_account.id
    blob            = join("/", [azurerm_storage_account.storage_account.id, "blobServices", "default"])
    queue           = join("/", [azurerm_storage_account.storage_account.id, "queueServices", "default"])
    file            = join("/", [azurerm_storage_account.storage_account.id, "fileServices", "default"])
    table           = join("/", [azurerm_storage_account.storage_account.id, "tableServices", "default"])
    dfs             = join("/", [azurerm_storage_account.storage_account.id, "dfsServices", "default"])
  }

  diagnostic_scopes = distinct([
    for ds in var.diagnostic_settings : try(ds.scope, "storage_account")
  ])
}

data "azurerm_monitor_diagnostic_categories" "storage" {
  for_each    = { for scope in local.diagnostic_scopes : scope => local.diagnostic_scope_ids[scope] }
  resource_id = each.value
}

locals {
  diag_log_categories_by_scope = {
    for scope, ds in data.azurerm_monitor_diagnostic_categories.storage : scope => ds.log_category_types
  }

  diag_metric_categories_by_scope = {
    for scope, ds in data.azurerm_monitor_diagnostic_categories.storage : scope => ds.metrics
  }

  diag_area_log_map = {
    for scope, categories in local.diag_log_categories_by_scope : scope => {
      all    = categories
      read   = [for c in ["StorageRead"] : c if contains(categories, c)]
      write  = [for c in ["StorageWrite"] : c if contains(categories, c)]
      delete = [for c in ["StorageDelete"] : c if contains(categories, c)]
    }
  }

  diag_area_metric_map = {
    for scope, categories in local.diag_metric_categories_by_scope : scope => {
      all         = categories
      metrics     = categories
      transaction = [for c in ["Transaction"] : c if contains(categories, c)]
      capacity    = [for c in ["Capacity"] : c if contains(categories, c)]
    }
  }

  diagnostic_settings_resolved = [
    for ds in var.diagnostic_settings : merge(ds, {
      scope = try(ds.scope, "storage_account")
      areas = ds.areas != null ? ds.areas : ["all"]
      log_categories = ds.log_categories != null ? [
        for c in ds.log_categories : c
        if contains(lookup(local.diag_log_categories_by_scope, try(ds.scope, "storage_account"), []), c)
        ] : distinct(flatten([
          for area in(ds.areas != null ? ds.areas : ["all"]) :
          lookup(lookup(local.diag_area_log_map, try(ds.scope, "storage_account"), {}), area, [])
      ]))
      metric_categories = ds.metric_categories != null ? [
        for c in ds.metric_categories : c
        if contains(lookup(local.diag_metric_categories_by_scope, try(ds.scope, "storage_account"), []), c)
        ] : distinct(flatten([
          for area in(ds.areas != null ? ds.areas : ["all"]) :
          lookup(lookup(local.diag_area_metric_map, try(ds.scope, "storage_account"), {}), area, [])
      ]))
    })
  ]

  diagnostic_settings_resolved_by_name = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
  }

  diagnostic_settings_for_each = {
    for ds in var.diagnostic_settings : ds.name => ds
    if !(
      ds.log_categories != null && length(ds.log_categories) == 0 &&
      ds.metric_categories != null && length(ds.metric_categories) == 0
    )
  }

  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_resolved : {
      name              = ds.name
      scope             = ds.scope
      areas             = ds.areas
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if length(ds.log_categories) + length(ds.metric_categories) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each = local.diagnostic_settings_for_each

  name               = each.value.name
  target_resource_id = local.diagnostic_scope_ids[local.diagnostic_settings_resolved_by_name[each.key].scope]

  log_analytics_workspace_id     = try(local.diagnostic_settings_resolved_by_name[each.key].log_analytics_workspace_id, null)
  log_analytics_destination_type = try(local.diagnostic_settings_resolved_by_name[each.key].log_analytics_destination_type, null)
  storage_account_id             = try(local.diagnostic_settings_resolved_by_name[each.key].storage_account_id, null)
  eventhub_authorization_rule_id = try(local.diagnostic_settings_resolved_by_name[each.key].eventhub_authorization_rule_id, null)
  eventhub_name                  = try(local.diagnostic_settings_resolved_by_name[each.key].eventhub_name, null)

  dynamic "enabled_log" {
    for_each = local.diagnostic_settings_resolved_by_name[each.key].log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = local.diagnostic_settings_resolved_by_name[each.key].metric_categories
    content {
      category = enabled_metric.value
    }
  }
}
