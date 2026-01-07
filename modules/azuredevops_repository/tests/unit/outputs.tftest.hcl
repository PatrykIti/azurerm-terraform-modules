# Test outputs for Azure DevOps Repository

mock_provider "azuredevops" {
  mock_resource "azuredevops_git_repository" {
    defaults = {
      id      = "00000000-0000-0000-0000-000000000001"
      web_url = "https://dev.azure.com/org/project/_git/repo"
    }
  }

  mock_resource "azuredevops_git_repository_branch" {
    defaults = {
      id = "repo-0001:main"
    }
  }

  mock_resource "azuredevops_branch_policy_min_reviewers" {
    defaults = {
      id = "policy-0001"
    }
  }
}

variables {
  project_id     = "00000000-0000-0000-0000-000000000000"
  name           = "example-repo"
  initialization = {}

  branches = [
    {
      name       = "main"
      ref_branch = "refs/heads/main"
      policies = {
        min_reviewers = {
          reviewer_count = 1
        }
      }
    }
  ]
}

run "outputs_apply" {
  command = apply

  assert {
    condition     = output.repository_id == "00000000-0000-0000-0000-000000000001"
    error_message = "repository_id should match the mocked repository ID."
  }

  assert {
    condition     = output.repository_url == "https://dev.azure.com/org/project/_git/repo"
    error_message = "repository_url should match the mocked repository URL."
  }

  assert {
    condition     = contains(keys(output.branch_ids), "main")
    error_message = "branch_ids should be keyed by branch name."
  }

  assert {
    condition     = contains(keys(output.policy_ids.branch_min_reviewers), "main")
    error_message = "policy_ids.branch_min_reviewers should be keyed by branch name."
  }
}
