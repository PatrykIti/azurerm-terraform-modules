provider "azuredevops" {}

module "azuredevops_repository" {
  source = "../../"

  project_id = var.project_id

  repositories = {
    main = {
      name = "ado-repo-secure"
      initialization = {
        init_type = "Clean"
      }
    }
  }

  branch_policy_min_reviewers = [
    {
      key            = "min-reviewers-main"
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
      key          = "status-check-main"
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
      key             = "check-credentials-main"
      repository_keys = ["main"]
    }
  ]

  repository_policy_case_enforcement = [
    {
      key                     = "case-enforcement-main"
      enforce_consistent_case = true
      repository_keys         = ["main"]
    }
  ]
}
