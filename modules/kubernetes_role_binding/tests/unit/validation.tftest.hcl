# Placeholder validation test for Kubernetes Role Binding

variables {
  name                = "example-kubernetes_role_binding"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "validation_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update validation tests for Kubernetes Role Binding."
  }
}
