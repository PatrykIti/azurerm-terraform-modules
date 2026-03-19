# Placeholder outputs test for Kubernetes Namespace

variables {
  name                = "example-kubernetes_namespace"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update outputs tests for Kubernetes Namespace."
  }
}
