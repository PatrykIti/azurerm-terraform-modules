# Placeholder outputs test for Kubernetes Role Binding

variables {
  name                = "example-kubernetes_role_binding"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update outputs tests for Kubernetes Role Binding."
  }
}
