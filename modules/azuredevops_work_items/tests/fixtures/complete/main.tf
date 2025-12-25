provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

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
        SELECT [System.Id], [System.Title]
        FROM WorkItems
        WHERE [System.WorkItemType] = 'Issue'
          AND [System.State] <> 'Closed'
      WIQL
    }
  ]

  work_items = [
    {
      title = "${var.work_item_title_prefix}-complete"
      type  = "Issue"
      state = "Active"
    }
  ]
}
