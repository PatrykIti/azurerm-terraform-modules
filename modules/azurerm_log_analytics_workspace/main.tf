resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku                                = var.workspace.sku
  retention_in_days                  = var.workspace.retention_in_days
  daily_quota_gb                     = try(var.workspace.daily_quota_gb, null)
  reservation_capacity_in_gb_per_day = try(var.workspace.reservation_capacity_in_gb_per_day, null)
  internet_ingestion_enabled         = var.workspace.internet_ingestion_enabled
  internet_query_enabled             = var.workspace.internet_query_enabled
  local_authentication_enabled       = var.workspace.local_authentication_enabled
  allow_resource_only_permissions    = try(var.workspace.allow_resource_only_permissions, null)

  tags = var.tags

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(var.workspace.timeouts, null) == null ? [] : [var.workspace.timeouts]

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}

resource "azurerm_log_analytics_solution" "log_analytics_solution" {
  for_each = { for solution in var.features.solutions : solution.name => solution }

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
  for_each = { for data_export_rule in var.features.data_export_rules : data_export_rule.name => data_export_rule }

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  workspace_resource_id   = azurerm_log_analytics_workspace.log_analytics_workspace.id
  destination_resource_id = each.value.destination_resource_id
  table_names             = each.value.table_names
  enabled                 = try(each.value.enabled, true)
}

resource "azurerm_log_analytics_datasource_windows_event" "log_analytics_datasource_windows_event" {
  for_each = { for windows_event_datasource in var.features.windows_event_datasources : windows_event_datasource.name => windows_event_datasource }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  workspace_name      = azurerm_log_analytics_workspace.log_analytics_workspace.name
  event_log_name      = each.value.event_log_name
  event_types         = each.value.event_types
}

resource "azurerm_log_analytics_datasource_windows_performance_counter" "log_analytics_datasource_windows_performance_counter" {
  for_each = { for windows_performance_counter in var.features.windows_performance_counters : windows_performance_counter.name => windows_performance_counter }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  workspace_name      = azurerm_log_analytics_workspace.log_analytics_workspace.name
  object_name         = each.value.object_name
  instance_name       = each.value.instance_name
  counter_name        = each.value.counter_name
  interval_seconds    = each.value.interval_seconds
}

resource "azurerm_log_analytics_storage_insights" "log_analytics_storage_insights" {
  for_each = { for storage_insight in var.features.storage_insights : storage_insight.name => storage_insight }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  storage_account_id  = each.value.storage_account_id
  storage_account_key = each.value.storage_account_key

  blob_container_names = try(each.value.blob_container_names, null)
  table_names          = try(each.value.table_names, null)
}

resource "azurerm_log_analytics_linked_service" "log_analytics_linked_service" {
  for_each = { for linked_service in var.features.linked_services : linked_service.name => linked_service }

  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  read_access_id      = each.value.read_access_id
  write_access_id     = try(each.value.write_access_id, null)
}

resource "azurerm_log_analytics_cluster" "log_analytics_cluster" {
  for_each = { for cluster in var.features.clusters : cluster.name => cluster }

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
  for_each = { for cluster_customer_managed_key in var.features.cluster_customer_managed_keys : cluster_customer_managed_key.name => cluster_customer_managed_key }

  log_analytics_cluster_id = coalesce(
    try(each.value.log_analytics_cluster_id, null),
    try(azurerm_log_analytics_cluster.log_analytics_cluster[each.value.cluster_name].id, null)
  )
  key_vault_key_id = each.value.key_vault_key_id
}
