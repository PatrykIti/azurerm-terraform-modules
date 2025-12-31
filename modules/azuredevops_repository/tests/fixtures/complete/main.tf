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
      name = "develop"
      policies = {
        min_reviewers = {
          reviewer_count = 1
        }
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

  policies = {
    reserved_names = {
      blocking = true
    }
  }
}
