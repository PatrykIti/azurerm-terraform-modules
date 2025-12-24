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
    main = {
      initialization = {
        init_type = "Clean"
      }
    }
  }

  branches = [
    {
      repository_key = "main"
      name           = "main"
      ref_branch     = "refs/heads/master"
    }
  ]

  branch_policy_min_reviewers = [
    {
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
    condition     = length(keys(output.branch_ids)) == 1
    error_message = "branch_ids should include configured branches."
  }

  assert {
    condition     = length(keys(output.policy_ids.branch_min_reviewers)) == 1
    error_message = "policy_ids should include configured branch policies."
  }
}
