# Test variable validation for Azure DevOps Pipelines

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_branch_selector" {
  command = plan

  variables {
    branches = [
      {
        repository_id  = "00000000-0000-0000-0000-000000000000"
        repository_key = "main"
        name           = "invalid"
      }
    ]
  }

  expect_failures = [
    var.branches,
  ]
}
