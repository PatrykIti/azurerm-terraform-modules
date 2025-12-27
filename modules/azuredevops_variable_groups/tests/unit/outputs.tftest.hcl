# Test outputs for Azure DevOps Variable Groups

mock_provider "azuredevops" {
  mock_resource "azuredevops_variable_group" {
    defaults = {
      id   = "vg-0001"
      name = "shared-vars"
    }
    override_during = plan
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "shared-vars"

  variables = [
    {
      name  = "key"
      value = "value"
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = output.variable_group_id == "vg-0001"
    error_message = "variable_group_id should reflect the created variable group ID."
  }

  assert {
    condition     = output.variable_group_name == "shared-vars"
    error_message = "variable_group_name should reflect the created variable group name."
  }
}
