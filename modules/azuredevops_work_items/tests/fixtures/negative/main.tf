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
  source = "../../../"

  project_id = var.project_id

  query_folders = [
    {
      name      = "Invalid"
      area      = "Shared Queries"
      parent_id = "00000000-0000-0000-0000-000000000001"
    }
  ]
}
