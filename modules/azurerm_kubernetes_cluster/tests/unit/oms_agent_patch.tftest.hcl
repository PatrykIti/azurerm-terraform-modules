# OMS Agent AMPLS patch unit tests

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }
}

mock_provider "azapi" {}

variables {
  name                = "akstestcluster"
  resource_group_name = "test-rg"
  location            = "northeurope"
  dns_config = {
    dns_prefix = "akstest"
  }
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
}

run "oms_agent_without_ampls_no_patch" {
  command = plan

  variables {
    oms_agent = {
      log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
    }
  }

  assert {
    condition     = length(azapi_update_resource.kubernetes_cluster_oms_agent_patch) == 0
    error_message = "OMS agent patch should be skipped when ampls_resource_id is not provided."
  }
}

run "oms_agent_ampls_patch_applied" {
  command = plan

  variables {
    oms_agent = {
      log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      ampls_resource_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Insights/privateLinkScopes/test-ampls"
      collection_profile          = "advanced"
    }
  }

  assert {
    condition     = length(azapi_update_resource.kubernetes_cluster_oms_agent_patch) == 1
    error_message = "OMS agent patch should be created when ampls_resource_id is set."
  }

  assert {
    condition     = jsondecode(azapi_update_resource.kubernetes_cluster_oms_agent_patch[0].body).properties.addonProfiles.omsagent.config.useAzureMonitorPrivateLinkScope == "true"
    error_message = "OMS agent patch should enable Azure Monitor Private Link Scope."
  }

  assert {
    condition     = jsondecode(azapi_update_resource.kubernetes_cluster_oms_agent_patch[0].body).properties.addonProfiles.omsagent.config.azureMonitorPrivateLinkScopeResourceId == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Insights/privateLinkScopes/test-ampls"
    error_message = "OMS agent patch should set the AMPLS resource ID."
  }

  assert {
    condition     = contains(jsondecode(jsondecode(azapi_update_resource.kubernetes_cluster_oms_agent_patch[0].body).properties.addonProfiles.omsagent.config.dataCollectionSettings).streams, "Microsoft-ContainerLogV2")
    error_message = "Advanced collection profile should include Microsoft-ContainerLogV2 stream."
  }

  assert {
    condition     = contains(jsondecode(jsondecode(azapi_update_resource.kubernetes_cluster_oms_agent_patch[0].body).properties.addonProfiles.omsagent.config.dataCollectionSettings).streams, "Microsoft-KubeEvents")
    error_message = "Advanced collection profile should include Microsoft-KubeEvents stream."
  }
}
