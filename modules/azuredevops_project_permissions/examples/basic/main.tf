provider "azuredevops" {}

module "azuredevops_project_permissions" {
  source = "../../"

  project_id = var.project_id

  permissions = [
    {
      key        = "collection-admins"
      group_name = var.collection_group_name
      scope      = "collection"
      permissions = {
        GENERIC_READ = "Allow"
      }
      replace = false
    }
  ]
}
