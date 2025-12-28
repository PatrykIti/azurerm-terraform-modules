provider "azuredevops" {}

module "azuredevops_environments" {
  source = "../../"

  project_id  = var.project_id
  name        = "ado-env-basic-example"
  description = "Development environment"
}
