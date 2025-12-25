# Test outputs for Azure DevOps Service Hooks

mock_provider "azuredevops" {
  mock_resource "azuredevops_servicehook_webhook_tfs" {
    defaults = {
      id = "hook-0001"
    }
  }

  mock_resource "azuredevops_servicehook_storage_queue_pipelines" {
    defaults = {
      id = "hook-0002"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  webhooks = [
    {
      url      = "https://example.com/webhook"
      git_push = {}
    }
  ]

  storage_queue_hooks = [
    {
      account_name            = "account"
      account_key             = "key"
      queue_name              = "queue"
      run_state_changed_event = {}
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.servicehook_ids.webhook_tfs)) == 1
    error_message = "servicehook_ids.webhook_tfs should include configured webhooks."
  }

  assert {
    condition     = length(keys(output.servicehook_ids.storage_queue_pipelines)) == 1
    error_message = "servicehook_ids.storage_queue_pipelines should include configured storage queue hooks."
  }
}
