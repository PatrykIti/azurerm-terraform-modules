terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_repository" {
  source = "../../../"

  project_id = var.project_id
  name       = "${var.repo_name_prefix}-secure"

  initialization = {
    init_type = "Clean"
  }

  branches = [
    {
      key  = "develop"
      name = "develop"
    }
  ]

  branch_policy_min_reviewers = [
    {
      key            = "min-reviewers"
      reviewer_count = 2
      blocking       = true
      scope = [
        {
          match_type     = "Exact"
          repository_ref = "refs/heads/develop"
        }
      ]
    }
  ]

  repository_policy_reserved_names = [
    {
      key      = "reserved-names"
      blocking = true
    }
  ]
}
