# Placeholder outputs test for Application Insights

variables {
  name                = "example-application_insights"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update outputs tests for Application Insights."
  }
}
