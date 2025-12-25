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
