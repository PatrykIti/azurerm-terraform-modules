# Test default settings for Azure DevOps Service Hooks

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_servicehook_webhook_tfs.webhook) == 0
    error_message = "No webhook service hook should be created by default."
  }

  assert {
    condition     = length(azuredevops_servicehook_storage_queue_pipelines.storage_queue) == 0
    error_message = "No storage queue service hook should be created by default."
  }

  assert {
    condition     = length(azuredevops_servicehook_permissions.servicehook_permissions) == 0
    error_message = "No service hook permissions should be created by default."
  }
}
