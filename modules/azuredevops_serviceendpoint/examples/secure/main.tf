provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_serviceendpoint" {
  source = "../../"

  project_id = var.project_id

  repositories = {
    main = {
      name = "${var.repo_name_prefix}-${random_string.suffix.result}"
      initialization = {
        init_type = "Clean"
      }
    }
  }

  branch_policy_min_reviewers = [
    {
      reviewer_count = var.reviewer_count
      scope = [
        {
          repository_key = "main"
          match_type     = "DefaultBranch"
        }
      ]
    }
  ]

  branch_policy_status_check = [
    {
      name         = var.status_check_name
      genre        = var.status_check_genre
      display_name = "Security Status Check"
      scope = [
        {
          repository_key = "main"
          match_type     = "DefaultBranch"
        }
      ]
    }
  ]

  repository_policy_check_credentials = [
    {
      repository_keys = ["main"]
    }
  ]

  repository_policy_case_enforcement = [
    {
      enforce_consistent_case = true
      repository_keys         = ["main"]
    }
  ]
}
