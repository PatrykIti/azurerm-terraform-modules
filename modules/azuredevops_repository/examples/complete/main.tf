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

locals {
  repositories = {
    app = {
      name = "ado-repo-complete-app"
    }
    shared = {
      name = "ado-repo-complete-shared"
    }
  }
}

module "azuredevops_repository" {
  for_each = local.repositories
  source   = "../../"

  project_id = var.project_id
  name       = each.value.name

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

  git_permissions = [
    {
      key       = "contributors"
      principal = var.principal_descriptor
      permissions = {
        GenericRead       = "Allow"
        GenericContribute = "Allow"
      }
    }
  ]

  branch_policy_min_reviewers = [
    {
      key            = "min-reviewers"
      reviewer_count = var.reviewer_count
      scope = [
        {
          match_type = "DefaultBranch"
        }
      ]
    }
  ]

  branch_policy_build_validation = [
    {
      key                 = "build-validation"
      build_definition_id = var.build_definition_id
      display_name        = "CI"
      scope = [
        {
          match_type = "DefaultBranch"
        }
      ]
    }
  ]

  repository_policy_author_email_pattern = [
    {
      key                   = "author-email"
      author_email_patterns = var.author_email_patterns
    }
  ]

  repository_policy_reserved_names = [
    {
      key = "reserved-names"
    }
  ]
}
