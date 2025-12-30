# Test default settings for the Kubernetes Cluster module

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
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
  network_profile = {
    network_plugin = "azure"
  }
}

# Test default identity settings
run "verify_default_identity" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].type == "SystemAssigned"
    error_message = "Default identity type should be SystemAssigned"
  }
}

# Test service principal configuration works without requiring identity=null
run "verify_service_principal_config" {
  command = plan

  variables {
    service_principal = {
      client_id     = "00000000-0000-0000-0000-000000000000"
      client_secret = "dummy-secret"
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.service_principal[0].client_id == "00000000-0000-0000-0000-000000000000"
    error_message = "Service principal client_id should match input when service_principal is configured."
  }
}

# Test default SKU tier
run "verify_default_sku" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.sku_tier == "Free"
    error_message = "Default SKU tier should be Free"
  }
}

# Test default network profile settings
run "verify_default_network_profile" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].network_plugin == "azure"
    error_message = "Default network plugin should be azure"
  }
  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_sku == "standard"
    error_message = "Default load balancer SKU should be standard"
  }
}

# Test default feature flags
run "verify_default_features" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.azure_policy_enabled == false
    error_message = "Azure Policy should be disabled by default"
  }
  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.workload_identity_enabled == false
    error_message = "Workload Identity should be disabled by default"
  }
}
