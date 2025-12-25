provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

  area_permissions = [
    {
      principal = var.principal_descriptor
      path      = "/"
      permissions = {
        GENERIC_READ  = "Allow"
        GENERIC_WRITE = "Deny"
        CREATE_CHILDREN = "Deny"
        DELETE        = "Deny"
      }
    }
  ]

  iteration_permissions = [
    {
      principal = var.principal_descriptor
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
      principal = var.principal_descriptor
      permissions = {
        Enumerate = "allow"
        Create    = "deny"
        Update    = "deny"
        Delete    = "deny"
      }
    }
  ]
}
