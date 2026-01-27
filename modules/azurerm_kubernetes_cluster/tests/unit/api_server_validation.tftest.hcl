# Test API server access profile validation with private cluster

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
  name                = "test-aks"
  resource_group_name = "test-rg"
  location            = "northeurope"
  dns_config = {
    dns_prefix_private_cluster = "akstest"
  }
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
}

# Test that private cluster with authorized IP ranges fails validation
run "private_cluster_with_authorized_ips_fails" {
  command = plan

  variables {
    private_cluster_config = {
      private_cluster_enabled = true
    }
    api_server_access_profile = {
      authorized_ip_ranges = ["10.0.0.0/16"]
    }
  }

  expect_failures = [
    var.api_server_access_profile,
  ]
}

# Test that private cluster without authorized IP ranges passes
run "private_cluster_without_authorized_ips_passes" {
  command = plan

  variables {
    private_cluster_config = {
      private_cluster_enabled = true
    }
    api_server_access_profile = null
  }
}

# Test that public cluster with authorized IP ranges passes
run "public_cluster_with_authorized_ips_passes" {
  command = plan

  variables {
    dns_config = {
      dns_prefix = "akstest"
    }
    private_cluster_config = {
      private_cluster_enabled = false
    }
    api_server_access_profile = {
      authorized_ip_ranges = ["10.0.0.0/16"]
    }
  }
}

# Test that null api_server_access_profile doesn't cause errors
run "null_api_server_access_profile_passes" {
  command = plan

  variables {
    api_server_access_profile = null
    private_cluster_config = {
      private_cluster_enabled = true
    }
  }
}
