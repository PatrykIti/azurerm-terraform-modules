terraform {
  required_version = ">= 1.12.2"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }

    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_project" {
  source = "../../../"

  name               = "${var.project_name}-${random_string.suffix.result}"
  description        = "Test complete Azure DevOps project"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  features = {
    boards       = "enabled"
    repositories = "enabled"
    pipelines    = "enabled"
    testplans    = "disabled"
    artifacts    = "enabled"
  }

  pipeline_settings = {
    enforce_job_scope                    = true
    enforce_referenced_repo_scoped_token = true
    enforce_settable_var                 = true
    publish_pipeline_metadata            = false
    status_badges_are_private            = true
  }

  project_tags = ["test", "complete"]

  dashboards = [
    {
      name             = "Test Dashboard"
      description      = "Terratest dashboard"
      refresh_interval = 5
    }
  ]

}
