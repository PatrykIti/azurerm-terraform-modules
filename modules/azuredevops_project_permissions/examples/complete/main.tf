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

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

module "azuredevops_project_permissions" {
  source = "../../"

  project_id = var.project_id

  permissions = [
    {
      key        = "project-readers"
      group_name = var.project_group_name
      scope      = "project"
      permissions = {
        GENERIC_READ = "Allow"
      }
      replace = false
    },
    {
      key       = "collection-admins"
      principal = data.azuredevops_group.project_collection_admins.id
      permissions = {
        GENERIC_READ  = "Allow"
        GENERIC_WRITE = "Allow"
      }
      replace = false
    }
  ]
}
