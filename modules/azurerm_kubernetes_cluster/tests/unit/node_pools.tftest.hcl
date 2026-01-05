# Test conditional logic for additional node pools in the Kubernetes Cluster module

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }
  mock_resource "azurerm_kubernetes_cluster_node_pool" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks/agentPools/testpool"
      name = "testpool"
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
    name           = "default"
    vm_size        = "Standard_D2_v2"
    node_count     = 1
    vnet_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
  }
}

# Test that no additional node pools are created by default
run "no_additional_node_pools_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool) == 0
    error_message = "No additional node pools should be created when the node_pools variable is not set."
  }
}

# Test creation of a single additional node pool
run "single_additional_node_pool" {
  command = plan

  variables {
    node_pools = [
      {
        name       = "userpool1"
        vm_size    = "Standard_D2_v2"
        node_count = 2
      }
    ]
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool) == 1
    error_message = "Should create exactly one additional node pool."
  }
  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool["userpool1"].name == "userpool1"
    error_message = "Node pool name should match input."
  }
  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool["userpool1"].node_count == 2
    error_message = "Node count for the additional node pool should be 2."
  }
}

# Test creation of multiple additional node pools
run "multiple_additional_node_pools" {
  command = plan

  variables {
    node_pools = [
      {
        name       = "userpool1"
        vm_size    = "Standard_D2_v2"
        node_count = 1
      },
      {
        name       = "userpool2"
        vm_size    = "Standard_D4_v3"
        node_count = 3
      }
    ]
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool) == 2
    error_message = "Should create exactly two additional node pools."
  }
  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool["userpool2"].vm_size == "Standard_D4_v3"
    error_message = "VM size for the second node pool should be correct."
  }
}

# Test autoscaling node pool defaults node_count to min_count when not provided
run "autoscaling_node_pool_defaults_node_count" {
  command = plan

  variables {
    node_pools = [
      {
        name                 = "autoscale"
        vm_size              = "Standard_D2_v2"
        auto_scaling_enabled = true
        min_count            = 1
        max_count            = 2
      }
    ]
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool["autoscale"].node_count == 1
    error_message = "When auto_scaling_enabled is true and node_count is omitted, node_count should default to min_count."
  }
}
