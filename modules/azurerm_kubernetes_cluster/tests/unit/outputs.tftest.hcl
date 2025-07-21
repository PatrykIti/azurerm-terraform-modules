# Test output validation for the Kubernetes Cluster module

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/akstestcluster"
      name = "akstestcluster"
      fqdn = "akstestcluster-dns.westeurope.cloudapp.azure.com"
      identity = [{
        type         = "SystemAssigned"
        principal_id = "00000000-0000-0000-0000-000000000001"
        tenant_id    = "00000000-0000-0000-0000-000000000002"
      }]
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

# Test basic outputs
run "verify_basic_outputs" {
  command = plan

  override_resource {
    target = azurerm_kubernetes_cluster.kubernetes_cluster
    values = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/akstestcluster"
      name = "akstestcluster"
      fqdn = "akstestcluster-dns.westeurope.cloudapp.azure.com"
    }
    override_during = plan
  }

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/akstestcluster"
    error_message = "ID output should be the full resource ID"
  }

  assert {
    condition     = output.name == "akstestcluster"
    error_message = "Name output should match the cluster name"
  }

  assert {
    condition     = output.fqdn == "akstestcluster-dns.westeurope.cloudapp.azure.com"
    error_message = "FQDN output should be correct"
  }
}

# Test identity outputs
run "verify_identity_outputs" {
  command = plan

  override_resource {
    target = azurerm_kubernetes_cluster.kubernetes_cluster
    values = {
      identity = {
        type         = "SystemAssigned"
        principal_id = "00000000-0000-0000-0000-000000000001"
        tenant_id    = "00000000-0000-0000-0000-000000000002"
      }
    }
    override_during = plan
  }

  assert {
    condition     = output.identity.principal_id == "00000000-0000-0000-0000-000000000001"
    error_message = "Identity principal_id output should be correct"
  }

  assert {
    condition     = output.identity.tenant_id == "00000000-0000-0000-0000-000000000002"
    error_message = "Identity tenant_id output should be correct"
  }
}
