# Test outputs for Azure DevOps Service Hooks

mock_provider "azuredevops" {
  mock_resource "azuredevops_servicehook_webhook_tfs" {
    defaults = {
      id = "hook-0001"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  webhook = {
    url      = "https://example.com/webhook"
    git_push = {}
  }
}

run "outputs_plan" {
  command = apply

  assert {
    condition     = output.webhook_id == "hook-0001"
    error_message = "webhook_id should return the webhook ID."
  }
}
