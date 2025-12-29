# Test naming rules for the Azure DevOps Project module

mock_provider "azuredevops" {
  mock_resource "azuredevops_project" {
    defaults = {
      id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  name = "ado-project-naming"
}

run "valid_name" {
  command = plan
}

run "empty_name_fails" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [
    var.name,
  ]
}
