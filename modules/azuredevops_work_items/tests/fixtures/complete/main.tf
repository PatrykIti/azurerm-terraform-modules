provider "azuredevops" {}

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

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
        WHERE [System.WorkItemType] = 'Issue'
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

  work_items = [
    {
      key   = "parent-item"
      title = "${var.work_item_title_prefix}-parent"
      type  = "Issue"
      state = "Active"
    },
    {
      key        = "child-item"
      title      = "${var.work_item_title_prefix}-child"
      type       = "Issue"
      state      = "Active"
      parent_key = "parent-item"
    }
  ]
}
