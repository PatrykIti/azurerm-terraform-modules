# Validation tests for user entitlements

mock_provider "azuredevops" {}

run "missing_selector" {
  command = plan

  variables {
    user_entitlement = {
      key = "missing-selector"
    }
  }

  expect_failures = [
    var.user_entitlement,
  ]
}

run "invalid_selector_combination" {
  command = plan

  variables {
    user_entitlement = {
      key            = "invalid-selector"
      principal_name = "user@example.com"
      origin         = "aad"
      origin_id      = "22222222-2222-2222-2222-222222222222"
    }
  }

  expect_failures = [
    var.user_entitlement,
  ]
}

run "empty_key" {
  command = plan

  variables {
    user_entitlement = {
      key            = ""
      principal_name = "user@example.com"
    }
  }

  expect_failures = [
    var.user_entitlement,
  ]
}

run "empty_principal_name" {
  command = plan

  variables {
    user_entitlement = {
      principal_name = ""
    }
  }

  expect_failures = [
    var.user_entitlement,
  ]
}

run "empty_origin" {
  command = plan

  variables {
    user_entitlement = {
      origin    = ""
      origin_id = "11111111-1111-1111-1111-111111111111"
    }
  }

  expect_failures = [
    var.user_entitlement,
  ]
}

run "empty_origin_id" {
  command = plan

  variables {
    user_entitlement = {
      origin    = "aad"
      origin_id = ""
    }
  }

  expect_failures = [
    var.user_entitlement,
  ]
}

run "invalid_license_type" {
  command = plan

  variables {
    user_entitlement = {
      principal_name       = "user@example.com"
      account_license_type = "invalid"
    }
  }

  expect_failures = [
    var.user_entitlement,
  ]
}

run "invalid_licensing_source" {
  command = plan

  variables {
    user_entitlement = {
      principal_name   = "user@example.com"
      licensing_source = "invalid"
    }
  }

  expect_failures = [
    var.user_entitlement,
  ]
}
