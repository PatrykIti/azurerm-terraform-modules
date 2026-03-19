# Placeholder validation test for Kubernetes Cluster Role

variables {
  name                = "example-kubernetes_cluster_role"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "validation_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update validation tests for Kubernetes Cluster Role."
  }
}
