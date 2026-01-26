locals {
  aks_azapi_default_api_version = "2023-11-01"

  oms_agent_data_collection_settings_raw = var.oms_agent != null && var.oms_agent.data_collection_settings != null ? {
    interval               = var.oms_agent.data_collection_settings.interval
    namespaceFilteringMode = var.oms_agent.data_collection_settings.namespace_filtering_mode
    namespaces             = var.oms_agent.data_collection_settings.namespaces
    enableContainerLogV2   = var.oms_agent.data_collection_settings.enable_container_log_v2
    streams                = var.oms_agent.data_collection_settings.streams
  } : null

  oms_agent_data_collection_settings = local.oms_agent_data_collection_settings_raw == null ? null : {
    for key, value in local.oms_agent_data_collection_settings_raw : key => value if value != null
  }

  oms_agent_patch_config = merge(
    var.oms_agent != null && var.oms_agent.ampls_resource_id != null ? {
      useAzureMonitorPrivateLinkScope        = tostring(true)
      azureMonitorPrivateLinkScopeResourceId = var.oms_agent.ampls_resource_id
    } : {},
    local.oms_agent_data_collection_settings != null ? {
      dataCollectionSettings = jsonencode(local.oms_agent_data_collection_settings)
    } : {}
  )

  aks_azapi_patch_body_base = length(local.oms_agent_patch_config) > 0 ? {
    properties = {
      addonProfiles = {
        omsagent = {
          config = local.oms_agent_patch_config
        }
      }
    }
  } : {}

  aks_azapi_patch_body = var.aks_azapi_patch.enabled ? merge(local.aks_azapi_patch_body_base, var.aks_azapi_patch.body) : local.aks_azapi_patch_body_base

  aks_azapi_patch_enabled     = length(local.aks_azapi_patch_body) > 0
  aks_azapi_patch_api_version = coalesce(var.aks_azapi_patch.api_version, local.aks_azapi_default_api_version)
}

resource "azapi_update_resource" "kubernetes_cluster_patch" {
  count = local.aks_azapi_patch_enabled ? 1 : 0

  type        = "Microsoft.ContainerService/managedClusters@${local.aks_azapi_patch_api_version}"
  resource_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  body        = jsonencode(local.aks_azapi_patch_body)

  ignore_missing_property = true

  depends_on = [azurerm_kubernetes_cluster.kubernetes_cluster]
}
