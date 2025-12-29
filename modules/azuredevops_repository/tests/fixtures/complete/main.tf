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
  name       = "${var.repo_name_prefix}-complete"

  initialization = {
    init_type = "Clean"
  }

  branches = [
    {
      key  = "develop"
      name = "develop"
    }
  ]

  files = [
    {
      key                 = "readme"
      file                = "README.md"
      content             = "# Repository\n\nManaged by Terraform."
      commit_message      = "Add README"
      overwrite_on_create = true
    }
  ]

  branch_policy_min_reviewers = [
    {
      key            = "min-reviewers"
      reviewer_count = 1
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
      key = "reserved-names"
    }
  ]
}
