provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_project" {
  source = "../../"

  name               = "${var.project_name_prefix}-${random_string.suffix.result}"
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
