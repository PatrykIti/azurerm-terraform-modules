# Placeholder validation test for Kubernetes Role

variables {
  name                = "example-kubernetes_role"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "validation_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update validation tests for Kubernetes Role."
  }
}
