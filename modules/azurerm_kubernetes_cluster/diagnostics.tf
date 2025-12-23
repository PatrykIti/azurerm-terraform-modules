data "azurerm_monitor_diagnostic_categories" "aks" {
  count       = length(var.diagnostic_settings) > 0 ? 1 : 0
  resource_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
}

locals {
  # Whether any diagnostic settings are configured for this cluster.
  diagnostics_enabled = length(var.diagnostic_settings) > 0

  # All available log categories returned by Azure for this AKS resource.
  aks_diag_log_categories = local.diagnostics_enabled ? data.azurerm_monitor_diagnostic_categories.aks[0].log_category_types : []

  # All available metric categories returned by Azure for this AKS resource.
  aks_diag_metric_categories = local.diagnostics_enabled ? data.azurerm_monitor_diagnostic_categories.aks[0].metrics : []

  # Raw area-to-log mapping before filtering for availability.
  aks_area_log_map_raw = {
    api_plane          = ["kube-apiserver"]
    audit              = ["kube-audit", "kube-audit-admin"]
    controller_manager = ["kube-controller-manager"]
    scheduler          = ["kube-scheduler"]
    autoscaler         = ["cluster-autoscaler"]
    guard              = ["guard"]
    cloud_controller   = ["cloud-controller-manager"]
  }

  # Area-to-log mapping, filtered to categories that exist in the current region/version.
  aks_area_log_map = merge(
    { all = local.aks_diag_log_categories },
    { csi = [for c in local.aks_diag_log_categories : c if startswith(c, "csi-")] },
    { for k, v in local.aks_area_log_map_raw : k => [for c in v : c if contains(local.aks_diag_log_categories, c)] }
  )

  # Area-to-metric mapping; metrics are typically AllMetrics when available.
  aks_area_metric_map = {
    all     = local.aks_diag_metric_categories
    metrics = local.aks_diag_metric_categories
  }

  # Resolved settings with categories derived from areas unless explicitly provided.
  diagnostic_settings_resolved = [
    for ds in var.diagnostic_settings : merge(ds, {
      areas = ds.areas != null ? ds.areas : ["all"]
      log_categories = ds.log_categories != null ? ds.log_categories : distinct(flatten([
        for area in(ds.areas != null ? ds.areas : ["all"]) : lookup(local.aks_area_log_map, area, [])
      ]))
      metric_categories = ds.metric_categories != null ? ds.metric_categories : distinct(flatten([
        for area in(ds.areas != null ? ds.areas : ["all"]) : lookup(local.aks_area_metric_map, area, [])
      ]))
    })
  ]

  # Entries that still have categories after filtering.
  diagnostic_settings_effective = [
    for ds in local.diagnostic_settings_resolved : ds
    if length(ds.log_categories) + length(ds.metric_categories) > 0
  ]

  # Entries skipped due to having zero categories after filtering.
  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_resolved : {
      name              = ds.name
      areas             = ds.areas
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if length(ds.log_categories) + length(ds.metric_categories) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each           = { for ds in local.diagnostic_settings_effective : ds.name => ds }
  name               = each.value.name
  target_resource_id = azurerm_kubernetes_cluster.kubernetes_cluster.id

  log_analytics_workspace_id     = try(each.value.log_analytics_workspace_id, null)
  log_analytics_destination_type = try(each.value.log_analytics_destination_type, null)
  storage_account_id             = try(each.value.storage_account_id, null)
  eventhub_authorization_rule_id = try(each.value.eventhub_authorization_rule_id, null)
  eventhub_name                  = try(each.value.eventhub_name, null)

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
      enabled  = true
    }
  }
}
