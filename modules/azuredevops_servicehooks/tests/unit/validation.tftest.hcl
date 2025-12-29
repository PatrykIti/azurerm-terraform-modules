# Test validation for Azure DevOps Service Hooks

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_webhook_missing_event" {
  command = plan

  variables {
    webhook = {
      url = "https://example.com/webhook"
    }
  }

  expect_failures = [
    var.webhook,
  ]
}

run "invalid_webhook_multiple_events" {
  command = plan

  variables {
    webhook = {
      url               = "https://example.com/webhook"
      git_push          = {}
      work_item_created = {}
    }
  }

  expect_failures = [
    var.webhook,
  ]
}

run "invalid_webhook_messages" {
  command = plan

  variables {
    webhook = {
      url              = "https://example.com/webhook"
      git_push         = {}
      messages_to_send = "invalid"
    }
  }

  expect_failures = [
    var.webhook,
  ]
}

run "invalid_webhook_resource_details" {
  command = plan

  variables {
    webhook = {
      url                      = "https://example.com/webhook"
      git_push                 = {}
      resource_details_to_send = "verbose"
    }
  }

  expect_failures = [
    var.webhook,
  ]
}

run "invalid_tfvc_checkin_path" {
  command = plan

  variables {
    webhook = {
      url = "https://example.com/webhook"
      tfvc_checkin = {
        path = " "
      }
    }
  }

  expect_failures = [
    var.webhook,
  ]
}

run "invalid_storage_queue_missing_event" {
  command = plan

  variables {
    storage_queue_hook = {
      account_name = "account"
      account_key  = "key"
      queue_name   = "queue"
    }
  }

  expect_failures = [
    var.storage_queue_hook,
  ]
}

run "invalid_storage_queue_ttl" {
  command = plan

  variables {
    storage_queue_hook = {
      account_name            = "account"
      account_key             = "key"
      queue_name              = "queue"
      ttl                     = -1
      run_state_changed_event = {}
    }
  }

  expect_failures = [
    var.storage_queue_hook,
  ]
}

run "invalid_storage_queue_visi_timeout" {
  command = plan

  variables {
    storage_queue_hook = {
      account_name            = "account"
      account_key             = "key"
      queue_name              = "queue"
      visi_timeout            = -5
      run_state_changed_event = {}
    }
  }

  expect_failures = [
    var.storage_queue_hook,
  ]
}

run "invalid_permissions_empty" {
  command = plan

  variables {
    servicehook_permissions = [
      {
        principal   = "descriptor"
        permissions = {}
      }
    ]
  }

  expect_failures = [
    var.servicehook_permissions,
  ]
}

run "invalid_permissions_value" {
  command = plan

  variables {
    servicehook_permissions = [
      {
        principal = "descriptor"
        permissions = {
          ViewSubscriptions = "Banana"
        }
      }
    ]
  }

  expect_failures = [
    var.servicehook_permissions,
  ]
}

run "invalid_permissions_project_id" {
  command = plan

  variables {
    servicehook_permissions = [
      {
        principal  = "descriptor"
        project_id = " "
        permissions = {
          ViewSubscriptions = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.servicehook_permissions,
  ]
}

run "duplicate_permission_keys" {
  command = plan

  variables {
    servicehook_permissions = [
      {
        principal = "descriptor"
        permissions = {
          ViewSubscriptions = "Allow"
        }
      },
      {
        principal = "descriptor"
        permissions = {
          ViewSubscriptions = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.servicehook_permissions,
  ]
}
