locals {
  oms_agent_collection_profile = var.oms_agent != null ? try(var.oms_agent.collection_profile, "basic") : "basic"
  oms_agent_collection_streams = local.oms_agent_collection_profile == "advanced" ? [
    "Microsoft-Perf",
    "Microsoft-ContainerLogV2",
    "Microsoft-KubeEvents",
    "Microsoft-KubePodInventory",
    ] : [
    "Microsoft-Perf",
    "Microsoft-ContainerLogV2",
  ]
}

resource "azapi_update_resource" "kubernetes_cluster_oms_agent_patch" {
  count = var.oms_agent != null && var.oms_agent.ampls_settings != null && try(var.oms_agent.ampls_settings.enabled, true) ? 1 : 0

  type        = "Microsoft.ContainerService/managedClusters@2023-11-01"
  resource_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  body = jsonencode({
    properties = {
      addonProfiles = {
        omsagent = {
          config = {
            logAnalyticsWorkspaceResourceID        = var.oms_agent.log_analytics_workspace_id
            useAADAuth                             = tostring(var.oms_agent.msi_auth_for_monitoring_enabled)
            useAzureMonitorPrivateLinkScope        = tostring(true)
            azureMonitorPrivateLinkScopeResourceId = var.oms_agent.ampls_settings.id
            dataCollectionSettings = jsonencode({
              interval               = "1m"
              namespaceFilteringMode = var.oms_agent.namespaceFilteringMode
              enableContainerLogV2   = true
              streams                = local.oms_agent_collection_streams
            })
          }
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
