# Test repository naming defaults

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  repositories = {
    core = {
      initialization = {
        init_type = "Clean"
      }
    }
  }
}

run "repository_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_git_repository.repo) == 1
    error_message = "repositories should create one repo."
  }

  assert {
    condition     = azuredevops_git_repository.repo["core"].name == "core"
    error_message = "Repository name should default to the map key."
  }
}
