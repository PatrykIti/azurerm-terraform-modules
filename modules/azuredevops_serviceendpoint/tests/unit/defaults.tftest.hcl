# Test default settings for Azure DevOps Service Endpoints

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_git_repository.repo) == 0
    error_message = "No repositories should be created by default."
  }

  assert {
    condition     = length(azuredevops_git_repository_branch.branch) == 0
    error_message = "No branches should be created by default."
  }

  assert {
    condition     = length(azuredevops_git_repository_file.file) == 0
    error_message = "No files should be created by default."
  }
}
