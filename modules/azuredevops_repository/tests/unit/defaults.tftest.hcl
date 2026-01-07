# Test default settings for Azure DevOps Repository

mock_provider "azuredevops" {}

variables {
  project_id     = "00000000-0000-0000-0000-000000000000"
  name           = "default-repo"
  initialization = {}
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_git_repository.git_repository.name == "default-repo"
    error_message = "Repository resource should be created when name is provided."
  }

  assert {
    condition     = length(azuredevops_git_repository_branch.git_repository_branch) == 0
    error_message = "No branches should be created by default."
  }

  assert {
    condition     = length(azuredevops_git_repository_file.git_repository_file) == 0
    error_message = "No files should be created by default."
  }
}
