provider "azuredevops" {}

module "azuredevops_project_permissions" {
  source = "../../"

  project_id = var.project_id

  permissions = [
    {
      key        = "project-readers"
      group_name = var.project_group_name
      scope      = "project"
      permissions = {
        GENERIC_READ  = "Allow"
        GENERIC_WRITE = "NotSet"
      }
      replace = false
    }
  ]
}
