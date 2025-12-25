provider "azuredevops" {}

module "azuredevops_project_permissions" {
  source = "../../../"

  project_id = var.project_id

  permissions = [
    {
      key        = "collection-admins"
      group_name = "Project Collection Administrators"
      scope      = "collection"
      permissions = {
        GENERIC_READ = "Allow"
      }
      replace = false
    }
  ]
}
