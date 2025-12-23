# Placeholder outputs test for Kubernetes Secrets

variables {
  name                = "example-kubernetes_secrets"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update outputs tests for Kubernetes Secrets."
  }
}
