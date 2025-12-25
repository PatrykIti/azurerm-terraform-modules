# Test outputs for the Azure DevOps Project module

mock_provider "azuredevops" {
  mock_resource "azuredevops_project" {
    defaults = {
      id                  = "00000000-0000-0000-0000-000000000000"
      name                = "ado-project-outputs"
      process_template_id = "11111111-1111-1111-1111-111111111111"
    }
  }
}

variables {
  name = "ado-project-outputs"
}

run "outputs_plan" {
  command = apply

  assert {
    condition     = output.project_id != null
    error_message = "project_id output should not be null"
  }

  assert {
    condition     = output.project_name != null
    error_message = "project_name output should not be null"
  }
}
