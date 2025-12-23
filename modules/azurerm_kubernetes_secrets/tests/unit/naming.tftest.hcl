# Placeholder naming test for Kubernetes Secrets

variables {
  name                = "example-kubernetes_secrets"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "naming_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update naming tests for Kubernetes Secrets."
  }
}
