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

  title          = var.title
  type           = "Issue"
  state          = "Active"
  area_path      = var.area_path
  iteration_path = var.iteration_path
  tags           = ["terraform", "secure"]

  custom_fields = {
    "System.Description" = var.description
  }
}
