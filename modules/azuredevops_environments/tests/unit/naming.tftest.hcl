# Test environment naming defaults

mock_provider "azuredevops" {}

variables {
  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "core"
  description = "Core environment"
}

run "environment_plan" {
  command = plan

  assert {
    condition     = azuredevops_environment.environment.name == var.name
    error_message = "Environment name should match the provided name."
  }

  assert {
    condition     = azuredevops_environment.environment.description == var.description
    error_message = "Environment description should match the provided description."
  }
}
