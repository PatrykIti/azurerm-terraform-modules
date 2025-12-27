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
      name = "${var.repo_name_prefix}-complete"
      initialization = {
        init_type = "Clean"
      }
    }
  }

  branches = [
    {
      key            = "develop"
      repository_key = "main"
      name           = "develop"
      ref_branch     = "refs/heads/master"
    }
  ]

  files = [
    {
      key                 = "readme"
      repository_key      = "main"
      file                = "README.md"
      content             = "# Repository\n\nManaged by Terraform."
      commit_message      = "Add README"
      overwrite_on_create = true
    }
  ]

  branch_policy_min_reviewers = [
    {
      key            = "min-reviewers-main"
      reviewer_count = 1
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
