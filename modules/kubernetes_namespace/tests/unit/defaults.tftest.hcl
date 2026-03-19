# Placeholder defaults test for Kubernetes Namespace

variables {
  name                = "example-kubernetes_namespace"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update defaults tests for Kubernetes Namespace."
  }
}
