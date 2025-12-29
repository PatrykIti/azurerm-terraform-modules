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
  title      = "Example Work Item"
  type       = "Issue"
  state      = "Active"
  tags       = ["terraform"]
}
