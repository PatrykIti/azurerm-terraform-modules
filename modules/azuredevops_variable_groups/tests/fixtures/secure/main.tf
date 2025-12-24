provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_repository" {
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
      reviewer_count = 2
      scope = [
        {
          repository_key = "main"
          match_type     = "DefaultBranch"
        }
      ]
    }
  ]

  repository_policy_reserved_names = [
    {
      repository_keys = ["main"]
    }
  ]
}
