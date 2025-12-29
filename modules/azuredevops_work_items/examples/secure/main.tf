terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

  title = "Secure Example Work Item"
  type  = "Issue"

  area_permissions = [
    {
      key       = "area-readers-root"
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

  iteration_permissions = [
    {
      key       = "iteration-readers-root"
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
      key       = "tagging-readers"
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
