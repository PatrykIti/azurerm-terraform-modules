# Validation tests for service principal entitlements

mock_provider "azuredevops" {}

run "duplicate_keys" {
  command = plan

  variables {
    service_principal_entitlements = [
      {
        key                  = "dup"
        origin_id            = "00000000-0000-0000-0000-000000000000"
        account_license_type = "basic"
      },
      {
        key                  = "dup"
        origin_id            = "11111111-1111-1111-1111-111111111111"
        account_license_type = "basic"
      }
    ]
  }

  expect_failures = [
    var.service_principal_entitlements,
  ]
}

run "invalid_origin" {
  command = plan

  variables {
    service_principal_entitlements = [
      {
        key                  = "invalid-origin"
        origin_id            = "22222222-2222-2222-2222-222222222222"
        origin               = "custom"
        account_license_type = "basic"
      }
    ]
  }

  expect_failures = [
    var.service_principal_entitlements,
  ]
}
