provider "azuredevops" {}

module "azuredevops_variable_groups" {
  source = "../../"

  project_id = var.project_id
  name       = "${var.group_name_prefix}-network"

  description  = "Network validation group"
  allow_access = true

  variables = [
    {
      name  = "network"
      value = "enabled"
    }
  ]
}
