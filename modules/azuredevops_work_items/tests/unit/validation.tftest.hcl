# Test validation for Azure DevOps Work Items

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_query_folder" {
  command = plan

  variables {
    query_folders = [
      {
        name      = "Invalid"
        area      = "Shared Queries"
        parent_id = "00000000-0000-0000-0000-000000000000"
      }
    ]
  }

  expect_failures = [
    var.query_folders,
  ]
}
