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
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "example-repo"

  branches = [
    {
      key  = "main-branch"
      name = "main"
    }
  ]

  branch_policy_min_reviewers = [
    {
      key            = "min-reviewers"
      reviewer_count = 1
      scope = [
        {
          match_type = "DefaultBranch"
        }
      ]
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
    condition     = contains(keys(output.branch_ids), "main-branch")
    error_message = "branch_ids should be keyed by branch key."
  }

  assert {
    condition     = contains(keys(output.policy_ids.branch_min_reviewers), "min-reviewers")
    error_message = "policy_ids should be keyed by policy key."
  }
}
