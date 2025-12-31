# Test repository naming defaults

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "core"
}

run "repository_plan" {
  command = plan

  assert {
    condition     = azuredevops_git_repository.git_repository.name == "core"
    error_message = "Repository name should match the input name."
  }
}
