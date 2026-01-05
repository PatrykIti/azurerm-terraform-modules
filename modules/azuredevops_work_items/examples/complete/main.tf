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
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_work_items?ref=ADOWKv1.0.0"

  project_id = var.project_id

  processes = [
    {
      key                    = "custom"
      name                   = "custom_agile"
      parent_process_type_id = var.parent_process_type_id
      description            = "Custom agile process"
    }
  ]

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
        SELECT [System.Id], [System.Title], [System.State]
        FROM WorkItems
        WHERE [System.WorkItemType] = 'Issue'
          AND [System.State] <> 'Closed'
        ORDER BY [System.ChangedDate] DESC
      WIQL
    }
  ]

  query_permissions = [
    {
      key       = "active-issues-readers"
      query_key = "active-issues"
      principal = var.principal_descriptor
      permissions = {
        Read              = "Allow"
        Contribute        = "Deny"
        ManagePermissions = "Deny"
        Delete            = "Deny"
      }
    }
  ]

  title = "Example Work Item"
  type  = "Issue"
  state = "Active"
  tags  = ["terraform"]
}
