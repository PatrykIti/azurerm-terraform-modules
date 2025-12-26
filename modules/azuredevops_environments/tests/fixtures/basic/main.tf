provider "azuredevops" {}

module "azuredevops_environments" {
  source = "../.."

  project_id  = var.project_id
  name        = var.environment_name
  description = "Basic environment"
}
