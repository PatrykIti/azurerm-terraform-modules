# Test validation for Azure DevOps Service Hooks

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_webhook" {
  command = plan

  variables {
    webhooks = [
      {
        url = "https://example.com/webhook"
      }
    ]
  }

  expect_failures = [
    var.webhooks,
  ]
}
