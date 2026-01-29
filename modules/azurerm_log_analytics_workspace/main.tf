locals {
  solutions_by_name                     = { for s in var.solutions : s.name => s }
  data_export_rules_by_name             = { for r in var.data_export_rules : r.name => r }
  windows_event_datasources_by_name     = { for ds in var.windows_event_datasources : ds.name => ds }
  windows_performance_counters_by_name  = { for ds in var.windows_performance_counters : ds.name => ds }
  storage_insights_by_name              = { for si in var.storage_insights : si.name => si }
  linked_services_by_name               = { for ls in var.linked_services : ls.name => ls }
  clusters_by_name                      = { for c in var.clusters : c.name => c }
  cluster_customer_managed_keys_by_name = { for cmk in var.cluster_customer_managed_keys : cmk.name => cmk }
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku                               = var.sku
  retention_in_days                 = var.retention_in_days
  daily_quota_gb                    = var.daily_quota_gb
  reservation_capacity_in_gb_per_day = var.reservation_capacity_in_gb_per_day
  internet_ingestion_enabled        = var.internet_ingestion_enabled
  internet_query_enabled            = var.internet_query_enabled
  local_authentication_disabled     = var.local_authentication_disabled
  allow_resource_only_permissions   = var.allow_resource_only_permissions

  tags = var.tags

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }

  dynamic "timeouts" {
    for_each = (
      var.timeouts.create != null ||
      var.timeouts.update != null ||
      var.timeouts.delete != null ||
      var.timeouts.read != null
    ) ? [var.timeouts] : []

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}

resource "azurerm_log_analytics_solution" "log_analytics_solution" {
  for_each = local.solutions_by_name

  solution_name         = each.value.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher      = each.value.plan.publisher
    product        = each.value.plan.product
    promotion_code = try(each.value.plan.promotion_code, null)
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

resource "azurerm_log_analytics_data_export_rule" "log_analytics_data_export_rule" {
  for_each = local.data_export_rules_by_name

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  workspace_resource_id   = azurerm_log_analytics_workspace.log_analytics_workspace.id
  destination_resource_id = each.value.destination_resource_id
  table_names             = each.value.table_names
  enabled                 = try(each.value.enabled, true)
}

resource "azurerm_log_analytics_datasource_windows_event" "log_analytics_datasource_windows_event" {
  for_each = local.windows_event_datasources_by_name

  name                = each.value.name
  resource_group_name = var.resource_group_name
  workspace_name      = azurerm_log_analytics_workspace.log_analytics_workspace.name
  event_log_name      = each.value.event_log_name
  event_types         = each.value.event_types
}

resource "azurerm_log_analytics_datasource_windows_performance_counter" "log_analytics_datasource_windows_performance_counter" {
  for_each = local.windows_performance_counters_by_name

  name                = each.value.name
  resource_group_name = var.resource_group_name
  workspace_name      = azurerm_log_analytics_workspace.log_analytics_workspace.name
  object_name         = each.value.object_name
  instance_name       = each.value.instance_name
  counter_name        = each.value.counter_name
  interval_seconds    = each.value.interval_seconds
}

resource "azurerm_log_analytics_storage_insights" "log_analytics_storage_insights" {
  for_each = local.storage_insights_by_name

  name                = each.value.name
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  storage_account_id  = each.value.storage_account_id
  storage_account_key = each.value.storage_account_key

  blob_container_names = try(each.value.blob_container_names, null)
  table_names          = try(each.value.table_names, null)
}

resource "azurerm_log_analytics_linked_service" "log_analytics_linked_service" {
  for_each = local.linked_services_by_name

  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  read_access_id      = each.value.read_access_id
  write_access_id     = try(each.value.write_access_id, null)
}

resource "azurerm_log_analytics_cluster" "log_analytics_cluster" {
  for_each = local.clusters_by_name

  name                = each.value.name
  resource_group_name = coalesce(try(each.value.resource_group_name, null), var.resource_group_name)
  location            = coalesce(try(each.value.location, null), var.location)

  tags = merge(var.tags, try(each.value.tags, {}))

  dynamic "identity" {
    for_each = try(each.value.identity, null) != null ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }
}

resource "azurerm_log_analytics_cluster_customer_managed_key" "log_analytics_cluster_customer_managed_key" {
  for_each = local.cluster_customer_managed_keys_by_name

  log_analytics_cluster_id = coalesce(
    try(each.value.log_analytics_cluster_id, null),
    try(azurerm_log_analytics_cluster.log_analytics_cluster[each.value.cluster_name].id, null)
  )
  key_vault_key_id         = each.value.key_vault_key_id
}
