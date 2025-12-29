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

module "azuredevops_project" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_project?ref=ADOP1.0.0"

  name               = var.project_name
  description        = "Complete Azure DevOps project managed by Terraform"
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

  project_tags = ["complete", "terraform", "ado"]

  dashboards = [
    {
      name             = "Engineering Dashboard"
      description      = "Team engineering overview"
      refresh_interval = 5
    }
  ]

}
