# Test naming conventions for the Kubernetes Cluster module

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
  resource_group_name = "test-rg"
  location            = "northeurope"
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
}

# Test valid dns_prefix
run "valid_dns_prefix" {
  command = plan

  variables {
    name = "validakscluster"
    dns_config = {
      dns_prefix = "validdnsprefix"
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.dns_prefix == "validdnsprefix"
    error_message = "DNS prefix should be set correctly"
  }
}

# Test valid dns_prefix_private_cluster
run "valid_dns_prefix_private_cluster" {
  command = plan

  variables {
    name = "validakscluster"
    dns_config = {
      dns_prefix_private_cluster = "validprivateprefix"
    }
    private_cluster_config = {
      private_cluster_enabled = true
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.dns_prefix_private_cluster == "validprivateprefix"
    error_message = "Private DNS prefix should be set correctly"
  }
}
