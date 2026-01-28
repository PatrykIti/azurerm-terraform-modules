# Placeholder defaults test for Application Insights

variables {
  name                = "example-application_insights"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update defaults tests for Application Insights."
  }
}
