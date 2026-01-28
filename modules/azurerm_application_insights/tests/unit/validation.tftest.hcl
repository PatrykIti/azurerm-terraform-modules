# Placeholder validation test for Application Insights

variables {
  name                = "example-application_insights"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "validation_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update validation tests for Application Insights."
  }
}
