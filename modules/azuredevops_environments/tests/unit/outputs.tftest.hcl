# Test outputs for Azure DevOps Environments

mock_provider "azuredevops" {
  mock_resource "azuredevops_environment" {
    defaults = {
      id = "1"
    }
  }

  mock_resource "azuredevops_environment_resource_kubernetes" {
    defaults = {
      id = "k8s-0001"
    }
  }

  mock_resource "azuredevops_check_approval" {
    defaults = {
      id = "check-0001"
    }
  }
}

variables {
  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "dev"
  description = "Dev environment"

  kubernetes_resources = [
    {
      key                 = "dev-k8s"
      service_endpoint_id = "00000000-0000-0000-0000-000000000000"
      name                = "dev-k8s"
      namespace           = "default"
    }
  ]

  check_approvals = [
    {
      key                  = "approval-1"
      target_resource_type = "environment"
      approvers            = ["00000000-0000-0000-0000-000000000000"]
    }
  ]
}

run "outputs_apply" {
  command = apply

  assert {
    condition     = output.environment_id == "1"
    error_message = "environment_id should return the environment ID."
  }

  assert {
    condition     = length(keys(output.kubernetes_resource_ids)) == 1
    error_message = "kubernetes_resource_ids should include configured resources."
  }

  assert {
    condition     = length(keys(output.check_ids.approvals)) == 1
    error_message = "check_ids should include configured approvals."
  }
}
