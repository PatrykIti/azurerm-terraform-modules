# Placeholder defaults test for Kubernetes Secrets

variables {
  name                = "example-kubernetes_secrets"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update defaults tests for Kubernetes Secrets."
  }
}
