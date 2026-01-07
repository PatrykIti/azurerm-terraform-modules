# Validation tests for security role assignments

mock_provider "azuredevops" {}

run "missing_identity" {
  command = plan

  variables {
    scope       = "project"
    resource_id = "00000000-0000-0000-0000-000000000000"
    role_name   = "Reader"
    identity_id = ""
  }

  expect_failures = [
    var.identity_id,
  ]
}
