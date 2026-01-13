# Validate that a group selector is required

mock_provider "azuredevops" {}

run "group_selector_required" {
  command = plan

  variables {
    group_display_name = null
    group_origin_id    = null
    group_mail         = null
  }

  expect_failures = [
    var.group_display_name,
  ]
}

run "group_selector_conflict" {
  command = plan

  variables {
    group_display_name = "Conflicting Group"
    group_origin_id    = "00000000-0000-0000-0000-000000000000"
  }

  expect_failures = [
    var.group_display_name,
  ]
}
