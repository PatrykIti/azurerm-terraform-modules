# Placeholder defaults test for Kubernetes Role

variables {
  name                = "example-kubernetes_role"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update defaults tests for Kubernetes Role."
  }
}
