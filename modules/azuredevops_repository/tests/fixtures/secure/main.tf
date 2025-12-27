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

  repositories = {
    main = {
      name = "${var.repo_name_prefix}-secure"
      initialization = {
        init_type = "Clean"
      }
    }
  }

  branch_policy_min_reviewers = [
    {
      key            = "min-reviewers-main"
      reviewer_count = 2
      scope = [
        {
          repository_key = "main"
          match_type     = "Exact"
          repository_ref = "refs/heads/master"
        }
      ]
    }
  ]

  repository_policy_reserved_names = [
    {
      key             = "reserved-names-main"
      repository_keys = ["main"]
    }
  ]
}
