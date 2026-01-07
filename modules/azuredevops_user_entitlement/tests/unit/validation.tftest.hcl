# Validation tests for user entitlements

mock_provider "azuredevops" {}

run "duplicate_keys" {
  command = plan

  variables {
    user_entitlements = [
      {
        key                  = "dup"
        principal_name       = "user@example.com"
        account_license_type = "basic"
      },
      {
        key                  = "dup"
        principal_name       = "user2@example.com"
        account_license_type = "basic"
      }
    ]
  }

  expect_failures = [
    var.user_entitlements,
  ]
}

run "invalid_selector" {
  command = plan

  variables {
    user_entitlements = [
      {
        key            = "invalid-selector"
        principal_name = "user@example.com"
        origin_id      = "22222222-2222-2222-2222-222222222222"
        origin         = "aad"
        account_license_type = "basic"
      }
    ]
  }

  expect_failures = [
    var.user_entitlements,
  ]
}
