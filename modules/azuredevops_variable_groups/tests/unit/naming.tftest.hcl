# Test variable group naming

mock_provider "azuredevops" {}

variables {
  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "core-group"
  description = "Core variables"

  variables = [
    {
      name  = "key"
      value = "value"
    }
  ]
}

run "variable_group_plan" {
  command = plan

  assert {
    condition     = azuredevops_variable_group.variable_group.name == "core-group"
    error_message = "Variable group name should match the input name."
  }

  assert {
    condition     = azuredevops_variable_group.variable_group.description == "Core variables"
    error_message = "Variable group description should match the input description."
  }
}
