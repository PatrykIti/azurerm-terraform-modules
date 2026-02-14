# Test default settings for Azure DevOps Service Hooks

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  webhook = {
    url      = "https://example.com/webhook"
    git_push = {}
  }
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_servicehook_webhook_tfs.webhook.url == "https://example.com/webhook"
    error_message = "Webhook URL should match the input."
  }
}
