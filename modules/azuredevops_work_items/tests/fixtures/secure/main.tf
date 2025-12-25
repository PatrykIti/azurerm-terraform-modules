provider "azuredevops" {}

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

  area_permissions = [
    {
      principal = data.azuredevops_group.readers.id
      path      = "/"
      permissions = {
        GENERIC_READ    = "Allow"
        GENERIC_WRITE   = "Deny"
        CREATE_CHILDREN = "Deny"
        DELETE          = "Deny"
      }
    }
  ]

  tagging_permissions = [
    {
      principal = data.azuredevops_group.readers.id
      permissions = {
        Enumerate = "allow"
        Create    = "deny"
        Update    = "deny"
        Delete    = "deny"
      }
    }
  ]

  work_items = [
    {
      title = "Secure Work Item"
      type  = "Issue"
      state = "Active"
    }
  ]
}
