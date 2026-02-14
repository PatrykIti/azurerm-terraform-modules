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
  source = "../../../"

  project_id = var.project_id
  title      = "${var.work_item_title_prefix}-parent"
  type       = "Task"
  state      = "Active"
}

module "work_item_child" {
  source = "../../../"

  project_id = var.project_id
  title      = "${var.work_item_title_prefix}-child"
  type       = "Task"
  parent_id  = tonumber(module.work_item_parent.work_item_id)
}
