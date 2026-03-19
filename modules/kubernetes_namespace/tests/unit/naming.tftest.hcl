# Placeholder naming test for Kubernetes Namespace

variables {
  name                = "example-kubernetes_namespace"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "naming_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update naming tests for Kubernetes Namespace."
  }
}
