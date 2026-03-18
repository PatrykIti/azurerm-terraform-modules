# Test validation for Azure DevOps Service Hooks

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  webhook = {
    url      = "https://example.com/webhook"
    git_push = {}
  }
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
