# Placeholder outputs test for Kubernetes Role

variables {
  name                = "example-kubernetes_role"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update outputs tests for Kubernetes Role."
  }
}
