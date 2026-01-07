# Validate that a group selector is required

mock_provider "azuredevops" {}

run "group_selector_required" {
  command = plan

  variables {
    group_display_name = ""
  }

  expect_failures = [
    var.group_display_name,
  ]
}
