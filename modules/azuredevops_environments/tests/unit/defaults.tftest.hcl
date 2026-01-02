# Test default settings for Azure DevOps Environments

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "ado-env-defaults"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_environment.environment.name == var.name
    error_message = "Environment name should match the provided name."
  }

  assert {
    condition     = length(azuredevops_environment_resource_kubernetes.environment_resource_kubernetes) == 0
    error_message = "No Kubernetes resources should be created by default."
  }

  assert {
    condition     = length(azuredevops_check_approval.check_approval) == 0
    error_message = "No checks should be created by default."
  }
}
