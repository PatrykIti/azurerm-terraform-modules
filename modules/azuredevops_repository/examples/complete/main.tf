provider "azuredevops" {}

module "azuredevops_repository" {
  source = "../../"

  project_id = var.project_id

  repositories = {
    main = {
      name = "ado-repo-complete"
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

  git_permissions = [
    {
      key            = "main-contributors"
      repository_key = "main"
      principal      = var.principal_descriptor
      permissions = {
        GenericRead       = "Allow"
        GenericContribute = "Allow"
      }
    }
  ]

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

  branch_policy_build_validation = [
    {
      key                 = "build-validation-main"
      build_definition_id = var.build_definition_id
      display_name        = "CI"
      scope = [
        {
          repository_key = "main"
          match_type     = "DefaultBranch"
        }
      ]
    }
  ]

  repository_policy_author_email_pattern = [
    {
      key                   = "author-email-main"
      author_email_patterns = var.author_email_patterns
      repository_keys       = ["main"]
    }
  ]

  repository_policy_reserved_names = [
    {
      key             = "reserved-names-main"
      repository_keys = ["main"]
    }
  ]
}
