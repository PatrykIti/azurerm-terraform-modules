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

  webhook = {
    url      = "https://example.com/webhook"
    git_push = {}
  }

  storage_queue_hook = {
    account_name            = "account"
    account_key             = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
    queue_name              = "queue"
    run_state_changed_event = {}
  }

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
    condition     = output.webhook_id == "hook-0001"
    error_message = "webhook_id should return the webhook ID."
  }

  assert {
    condition     = output.storage_queue_hook_id == "hook-0002"
    error_message = "storage_queue_hook_id should return the storage queue hook ID."
  }

  assert {
    condition     = contains(keys(output.servicehook_permission_ids), "perm-main")
    error_message = "servicehook_permission_ids should include the permission key."
  }
}
