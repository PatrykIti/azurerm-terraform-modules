# Test variable validation for Azure DevOps Group Entitlement

mock_provider "azuredevops" {}

run "invalid_selector_both" {
  command = plan

  variables {
    group_entitlement = {
      display_name = "ADO Platform Team"
      origin       = "aad"
      origin_id    = "00000000-0000-0000-0000-000000000000"
    }
  }

  expect_failures = [
    var.group_entitlement,
  ]
}

run "invalid_selector_missing" {
  command = plan

  variables {
    group_entitlement = {
      key = "no-selector"
    }
  }

  expect_failures = [
    var.group_entitlement,
  ]
}

run "invalid_license_type" {
  command = plan

  variables {
    group_entitlement = {
      display_name         = "ADO Platform Team"
      account_license_type = "invalid"
    }
  }

  expect_failures = [
    var.group_entitlement,
  ]
}

run "invalid_licensing_source" {
  command = plan

  variables {
    group_entitlement = {
      display_name     = "ADO Platform Team"
      licensing_source = "invalid"
    }
  }

  expect_failures = [
    var.group_entitlement,
  ]
}
