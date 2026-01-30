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

module "work_item_parent" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  project_id = var.project_id

  title = "${var.work_item_title_prefix}-parent"
  type  = "Task"

  query_folders = [
    {
      key  = "team"
      name = "Team"
      area = "Shared Queries"
    }
  ]

  queries = [
    {
      key        = "active-issues"
      name       = "Active Issues"
      parent_key = "team"
      wiql       = <<-WIQL
        SELECT [System.Id], [System.Title]
        FROM WorkItems
        WHERE [System.WorkItemType] = 'Task'
          AND [System.State] <> 'Closed'
      WIQL
    }
  ]

  query_permissions = [
    {
      key       = "active-issues-readers"
      query_key = "active-issues"
      principal = data.azuredevops_group.readers.id
      permissions = {
        Read              = "Allow"
        Contribute        = "Deny"
        ManagePermissions = "Deny"
        Delete            = "Deny"
      }
    }
  ]
}

module "work_item_child" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  project_id = var.project_id

  title     = "${var.work_item_title_prefix}-child"
  type      = "Task"
  parent_id = module.work_item_parent.work_item_id
}
