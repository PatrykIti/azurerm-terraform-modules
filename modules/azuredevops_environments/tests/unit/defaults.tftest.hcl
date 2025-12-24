# Test default settings for Azure DevOps Environments

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_environment.environment) == 0
    error_message = "No environments should be created by default."
  }

  assert {
    condition     = length(azuredevops_environment_resource_kubernetes.kubernetes_resource) == 0
    error_message = "No Kubernetes resources should be created by default."
  }

  assert {
    condition     = length(azuredevops_check_approval.check_approval) == 0
    error_message = "No checks should be created by default."
  }
}
