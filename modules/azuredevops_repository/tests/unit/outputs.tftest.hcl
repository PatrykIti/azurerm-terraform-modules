# Test outputs for Azure DevOps Repository

mock_provider "azuredevops" {
  mock_resource "azuredevops_git_repository" {
    defaults = {
      id      = "repo-0001"
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

  repositories = {
    main = {}
  }

  branches = [
    {
      key            = "main-branch"
      repository_key = "main"
      name           = "main"
    }
  ]

  branch_policy_min_reviewers = [
    {
      key            = "min-reviewers-main"
      reviewer_count = 1
      scope = [
        {
          repository_key = "main"
          match_type     = "DefaultBranch"
        }
      ]
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.repository_ids)) == 1
    error_message = "repository_ids should include configured repositories."
  }

  assert {
    condition     = length(keys(output.repository_urls)) == 1
    error_message = "repository_urls should include configured repositories."
  }

  assert {
    condition     = contains(keys(output.branch_ids), "main-branch")
    error_message = "branch_ids should be keyed by branch key."
  }

  assert {
    condition     = contains(keys(output.policy_ids.branch_min_reviewers), "min-reviewers-main")
    error_message = "policy_ids should be keyed by policy key."
  }
}
