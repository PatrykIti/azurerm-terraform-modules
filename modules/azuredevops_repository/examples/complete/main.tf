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
  source   = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_repository?ref=ADORv1.0.3"

  project_id = var.project_id
  name       = each.value.name

  initialization = {
    init_type = "Clean"
  }

  branches = [
    {
      name       = "develop"
      ref_branch = "refs/heads/main"
      policies = {
        min_reviewers = {
          reviewer_count = var.reviewer_count
        }
        build_validation = [
          {
            name                = "ci"
            build_definition_id = var.build_definition_id
            display_name        = "CI"
          }
        ]
      }
    }
  ]

  files = [
    {
      file                = "README.md"
      content             = "# Repository\n\nManaged by Terraform."
      commit_message      = "Add README"
      overwrite_on_create = true
    }
  ]

  git_permissions = [
    {
      principal = var.principal_descriptor
      permissions = {
        GenericRead       = "Allow"
        GenericContribute = "Allow"
      }
    }
  ]

  policies = {
    author_email_pattern = {
      author_email_patterns = var.author_email_patterns
    }
    reserved_names = {
      blocking = true
    }
  }
}
