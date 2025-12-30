# Diagnostic settings unit tests for Kubernetes Cluster module

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/akstestcluster"
      name = "akstestcluster"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = [
        "kube-apiserver",
        "kube-audit",
        "kube-audit-admin",
        "kube-scheduler",
        "cluster-autoscaler",
        "guard",
        "cloud-controller-manager"
      ]
      metrics = ["AllMetrics"]
    }
  }
}

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

run "diagnostic_settings_valid" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "api-plane"
        areas                      = ["api_plane", "audit", "metrics"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 0
    error_message = "No diagnostic settings should be skipped when categories are available."
  }
}

run "diagnostic_settings_skips_empty_categories" {
  command = apply

  variables {
    diagnostic_settings = [
      {
        name                       = "empty-categories"
        log_categories             = []
        metric_categories          = []
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  assert {
    condition     = length(output.diagnostic_settings_skipped) == 1
    error_message = "Entries with no categories should be reported as skipped."
  }

  assert {
    condition     = output.diagnostic_settings_skipped[0].name == "empty-categories"
    error_message = "Skipped entry should include the original name."
  }
}
