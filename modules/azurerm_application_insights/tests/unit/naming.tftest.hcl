# Placeholder naming test for Application Insights

variables {
  name                = "example-application_insights"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "naming_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update naming tests for Application Insights."
  }
}
