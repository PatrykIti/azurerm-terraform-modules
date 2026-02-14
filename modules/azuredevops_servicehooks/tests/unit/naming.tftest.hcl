# Test webhook input mapping

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  webhook = {
    url = "https://example.com/webhook"
    build_completed = {
      definition_name = "pipeline-main"
      build_status    = "Succeeded"
    }
  }
}

run "webhook_plan" {
  command = plan

  assert {
    condition     = azuredevops_servicehook_webhook_tfs.webhook.url == "https://example.com/webhook"
    error_message = "webhook.url should be passed through."
  }
}
