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

module "work_item_parent" {
  source = "../../"

  project_id = var.project_id
  title      = var.parent_title
  type       = "Task"
  state      = "Active"
  tags       = ["terraform", "parent"]
}

module "work_item_child" {
  source = "../../"

  project_id = var.project_id
  title      = var.child_title
  type       = "Task"
  state      = "New"
  parent_id  = tonumber(module.work_item_parent.work_item_id)
  tags       = ["terraform", "child"]
}
