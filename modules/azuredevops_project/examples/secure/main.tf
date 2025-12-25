provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

module "azuredevops_project" {
  source = "../../"

  name               = "${var.project_name_prefix}-${random_string.suffix.result}"
  description        = "Secure Azure DevOps project managed by Terraform"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  features = {
    boards       = "enabled"
    repositories = "enabled"
    pipelines    = "enabled"
    testplans    = "disabled"
    artifacts    = "disabled"
  }

  pipeline_settings = {
    enforce_job_scope                    = true
    enforce_referenced_repo_scoped_token = true
    enforce_settable_var                 = true
    publish_pipeline_metadata            = false
    status_badges_are_private            = true
    enforce_job_scope_for_release        = true
  }

  project_tags = ["secure", "terraform", "ado"]

  project_permissions = [
    {
      principal = data.azuredevops_group.project_collection_admins.id
      permissions = {
        GENERIC_READ = "Allow"
      }
      replace = false
    }
  ]
}
