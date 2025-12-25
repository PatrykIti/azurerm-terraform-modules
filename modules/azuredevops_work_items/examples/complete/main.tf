provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

  processes = {
    custom = {
      name                   = "custom_agile"
      parent_process_type_id = var.parent_process_type_id
      description            = "Custom agile process"
    }
  }

  query_folders = [
    {
      name = "Team"
      area = "Shared Queries"
    }
  ]

  queries = [
    {
      name = "Active Issues"
      area = "Shared Queries"
      wiql = <<-WIQL
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
      principal = var.principal_descriptor
      permissions = {
        Read              = "Allow"
        Contribute        = "Deny"
        ManagePermissions = "Deny"
        Delete            = "Deny"
      }
    }
  ]

  work_items = [
    {
      title = "Example Work Item"
      type  = "Issue"
      state = "Active"
      tags  = ["terraform"]
    }
  ]
}
