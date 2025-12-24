# Test variable group naming defaults

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  variable_groups = {
    core = {
      allow_access = true
      variables = [
        {
          name  = "key"
          value = "value"
        }
      ]
    }
  }
}

run "variable_group_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_variable_group.variable_group) == 1
    error_message = "variable_groups should create one variable group."
  }

  assert {
    condition     = azuredevops_variable_group.variable_group["core"].name == "core"
    error_message = "Variable group name should default to the map key."
  }
}
