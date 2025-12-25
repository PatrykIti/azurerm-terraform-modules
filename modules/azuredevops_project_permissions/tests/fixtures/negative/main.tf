provider "azuredevops" {}

module "azuredevops_project_permissions" {
  source = "../../../"

  project_id = var.project_id

  permissions = [
    {
      group_name = "Readers"
      scope      = "team"
      permissions = {
        GENERIC_READ = "Allow"
      }
    }
  ]
}
