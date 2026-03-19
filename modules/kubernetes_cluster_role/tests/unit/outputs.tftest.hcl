# Placeholder outputs test for Kubernetes Cluster Role

variables {
  name                = "example-kubernetes_cluster_role"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update outputs tests for Kubernetes Cluster Role."
  }
}
