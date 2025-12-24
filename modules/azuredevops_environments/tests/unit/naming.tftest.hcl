# Test environment naming defaults

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  environments = {
    core = {}
  }
}

run "environment_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_environment.environment) == 1
    error_message = "environments should create one environment."
  }

  assert {
    condition     = azuredevops_environment.environment["core"].name == "core"
    error_message = "Environment name should default to the map key."
  }
}
