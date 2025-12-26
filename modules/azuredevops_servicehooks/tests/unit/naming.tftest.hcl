# Test webhook creation

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  webhooks = [
    {
      key      = "primary"
      url      = "https://example.com/webhook"
      git_push = {}
    }
  ]
}

run "webhook_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_servicehook_webhook_tfs.webhook) == 1
    error_message = "webhooks should create one service hook."
  }

  assert {
    condition     = contains(keys(azuredevops_servicehook_webhook_tfs.webhook), "primary")
    error_message = "webhooks should be keyed by the provided key."
  }
}
