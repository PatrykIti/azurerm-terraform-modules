# Placeholder naming test for Kubernetes Cluster Role Binding

variables {
  name                = "example-kubernetes_cluster_role_binding"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "naming_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update naming tests for Kubernetes Cluster Role Binding."
  }
}
