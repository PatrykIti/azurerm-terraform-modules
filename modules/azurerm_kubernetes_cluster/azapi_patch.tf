resource "azapi_update_resource" "kubernetes_cluster_oms_agent_patch" {
  count = var.oms_agent != null && (try(var.oms_agent.ampls_resource_id, null) != null || try(var.oms_agent.data_collection_settings, null) != null) ? 1 : 0

  type        = "Microsoft.ContainerService/managedClusters@2023-11-01"
  resource_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  body = jsonencode({
    properties = {
      addonProfiles = {
        omsagent = {
          config = merge(
            try(var.oms_agent.ampls_resource_id, null) != null ? {
              useAzureMonitorPrivateLinkScope        = tostring(true)
              azureMonitorPrivateLinkScopeResourceId = var.oms_agent.ampls_resource_id
            } : {},
            try(var.oms_agent.data_collection_settings, null) != null ? {
              dataCollectionSettings = jsonencode({
                for key, value in {
                  interval               = try(var.oms_agent.data_collection_settings.interval, null)
                  namespaceFilteringMode = try(var.oms_agent.data_collection_settings.namespace_filtering_mode, null)
                  namespaces             = try(var.oms_agent.data_collection_settings.namespaces, null)
                  enableContainerLogV2   = try(var.oms_agent.data_collection_settings.enable_container_log_v2, null)
                  streams                = try(var.oms_agent.data_collection_settings.streams, null)
                } : key => value if value != null
              })
            } : {}
          )
        }
      }
    }
  })

  ignore_missing_property = true

  depends_on = [azurerm_kubernetes_cluster.kubernetes_cluster]
}

resource "azapi_update_resource" "kubernetes_cluster_custom_patch" {
  count = var.aks_azapi_patch.enabled ? 1 : 0

  type        = "Microsoft.ContainerService/managedClusters@${coalesce(var.aks_azapi_patch.api_version, "2023-11-01")}"
  resource_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  body        = jsonencode(var.aks_azapi_patch.body)

  ignore_missing_property = true

  depends_on = [azurerm_kubernetes_cluster.kubernetes_cluster]
}
