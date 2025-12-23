# Pipeline settings fixture (formerly network)
provider "azuredevops" {}

module "azuredevops_project" {
  source = "../../../"

  project = {
    name = "ado-project-pipeline-fixture"
  }

  pipeline_settings = {
    enforce_job_scope                    = true
    enforce_referenced_repo_scoped_token = true
    status_badges_are_private            = true
  }
}
