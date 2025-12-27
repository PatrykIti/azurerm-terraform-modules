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
  command = apply

  assert {
    condition     = contains(keys(output.servicehook_ids.webhook_tfs), "webhook-main")
    error_message = "servicehook_ids.webhook_tfs should include the webhook key."
  }

  assert {
    condition     = contains(keys(output.servicehook_ids.storage_queue_pipelines), "queue-main")
    error_message = "servicehook_ids.storage_queue_pipelines should include the storage queue key."
  }

  assert {
    condition     = contains(keys(output.webhook_ids), "webhook-main")
    error_message = "webhook_ids should include the webhook key."
  }

  assert {
    condition     = contains(keys(output.storage_queue_hook_ids), "queue-main")
    error_message = "storage_queue_hook_ids should include the storage queue key."
  }

  assert {
    condition     = contains(keys(output.servicehook_permission_ids), "perm-main")
    error_message = "servicehook_permission_ids should include the permission key."
  }
}
