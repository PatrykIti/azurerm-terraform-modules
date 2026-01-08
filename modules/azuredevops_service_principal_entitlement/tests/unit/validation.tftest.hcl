# Validation tests for service principal entitlement inputs

mock_provider "azuredevops" {}

run "empty_origin_id" {
  command = plan

  variables {
    origin_id = ""
  }

  expect_failures = [
    var.origin_id,
  ]
}

run "invalid_origin" {
  command = plan

  variables {
    origin_id = "22222222-2222-2222-2222-222222222222"
    origin    = "custom"
  }

  expect_failures = [
    var.origin,
  ]
}

run "invalid_license_type" {
  command = plan

  variables {
    origin_id            = "33333333-3333-3333-3333-333333333333"
    account_license_type = "invalid"
  }

  expect_failures = [
    var.account_license_type,
  ]
}

run "invalid_licensing_source" {
  command = plan

  variables {
    origin_id        = "44444444-4444-4444-4444-444444444444"
    licensing_source = "invalid"
  }

  expect_failures = [
    var.licensing_source,
  ]
}
