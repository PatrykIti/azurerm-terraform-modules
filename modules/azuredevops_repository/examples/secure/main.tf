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
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_repository?ref=ADORv1.0.1"

  project_id = var.project_id
  name       = "ado-repo-secure"

  initialization = {
    init_type = "Clean"
  }

  branches = [
    {
      name       = "main"
      ref_branch = "refs/heads/main"
      policies = {
        min_reviewers = {
          reviewer_count                 = var.reviewer_count
          blocking                       = true
          submitter_can_vote             = false
          last_pusher_cannot_approve     = true
          on_last_iteration_require_vote = true
        }
        status_check = [
          {
            name         = var.status_check_name
            genre        = var.status_check_genre
            display_name = "Security Status Check"
          }
        ]
        work_item_linking = {
          enabled  = true
          blocking = true
        }
      }
    }
  ]

  policies = {
    author_email_pattern = {
      author_email_patterns = ["*@example.com"]
    }
    case_enforcement = {
      enforce_consistent_case = true
      blocking                = true
    }
    reserved_names = {
      blocking = true
    }
  }
}
