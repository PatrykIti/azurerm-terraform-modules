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

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_work_items" {
  source = "../../../"

  project_id = var.project_id

  title = "${var.work_item_title_prefix}-secure"
  type  = "Task"

  area_permissions = [
    {
      key       = "area-readers-root"
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

  iteration_permissions = [
    {
      key       = "iteration-readers-root"
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
      key       = "tagging-readers"
      principal = data.azuredevops_group.readers.id
      permissions = {
        Enumerate = "allow"
        Create    = "deny"
        Update    = "deny"
        Delete    = "deny"
      }
    }
  ]
}
