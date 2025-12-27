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

  mock_resource "azuredevops_servicehook_permissions" {
    defaults = {
      id = "perm-0001"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  webhooks = [
    {
      key      = "webhook-main"
      url      = "https://example.com/webhook"
      git_push = {}
    }
  ]

  storage_queue_hooks = [
    {
      key                     = "queue-main"
      account_name            = "account"
      account_key             = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
      queue_name              = "queue"
      run_state_changed_event = {}
    }
  ]

  servicehook_permissions = [
    {
      key       = "perm-main"
      principal = "descriptor"
      permissions = {
        ViewSubscriptions = "Allow"
      }
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = output.servicehook_ids.webhook_tfs["webhook-main"] == "hook-0001"
    error_message = "servicehook_ids.webhook_tfs should use stable webhook keys."
  }

  assert {
    condition     = output.servicehook_ids.storage_queue_pipelines["queue-main"] == "hook-0002"
    error_message = "servicehook_ids.storage_queue_pipelines should use stable storage queue keys."
  }

  assert {
    condition     = output.webhook_ids["webhook-main"] == "hook-0001"
    error_message = "webhook_ids should include the webhook keyed by webhook key."
  }

  assert {
    condition     = output.storage_queue_hook_ids["queue-main"] == "hook-0002"
    error_message = "storage_queue_hook_ids should include the queue hook keyed by hook key."
  }

  assert {
    condition     = output.servicehook_permission_ids["perm-main"] == "perm-0001"
    error_message = "servicehook_permission_ids should include the permission keyed by permission key."
  }
}
