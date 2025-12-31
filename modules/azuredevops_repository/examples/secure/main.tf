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
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_repository?ref=ADOR1.0.0"

  project_id = var.project_id
  name       = "ado-repo-secure"

  initialization = {
    init_type = "Clean"
  }

  branch_policy_min_reviewers = [
    {
      key                            = "min-reviewers"
      reviewer_count                 = var.reviewer_count
      blocking                       = true
      submitter_can_vote             = false
      last_pusher_cannot_approve     = true
      on_last_iteration_require_vote = true
      scope = [
        {
          match_type = "DefaultBranch"
        }
      ]
    }
  ]

  branch_policy_status_check = [
    {
      key          = "status-check"
      name         = var.status_check_name
      genre        = var.status_check_genre
      display_name = "Security Status Check"
      scope = [
        {
          match_type = "DefaultBranch"
        }
      ]
    }
  ]

  branch_policy_work_item_linking = [
    {
      key      = "work-item-linking"
      enabled  = true
      blocking = true
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
      author_email_patterns = ["*@example.com"]
    }
  ]

  repository_policy_case_enforcement = [
    {
      key                     = "case-enforcement"
      enforce_consistent_case = true
      blocking                = true
    }
  ]

  repository_policy_reserved_names = [
    {
      key      = "reserved-names"
      blocking = true
    }
  ]
}
