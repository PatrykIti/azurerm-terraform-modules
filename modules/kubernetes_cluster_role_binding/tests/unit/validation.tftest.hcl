# Placeholder validation test for Kubernetes Cluster Role Binding

variables {
  name                = "example-kubernetes_cluster_role_binding"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "validation_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update validation tests for Kubernetes Cluster Role Binding."
  }
}
