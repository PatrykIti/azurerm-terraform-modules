provider "azuredevops" {}

module "azuredevops_variable_groups" {
  source = "../../"

  project_id = var.project_id
  name       = "shared-vars"

  description  = "Basic variable group"
  allow_access = true

  variables = [
    {
      name  = "environment"
      value = "dev"
    },
    {
      name  = "region"
      value = "westeurope"
    }
  ]
}
