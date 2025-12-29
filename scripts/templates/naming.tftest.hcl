# Placeholder naming test for MODULE_DISPLAY_NAME_PLACEHOLDER

variables {
  name                = "example-MODULE_TYPE_PLACEHOLDER"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "naming_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update naming tests for MODULE_DISPLAY_NAME_PLACEHOLDER."
  }
}
