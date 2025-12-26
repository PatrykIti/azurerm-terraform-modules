provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

  query_folders = [
    {
      name      = "Invalid"
      area      = "Shared Queries"
      parent_id = 1
    }
  ]
}
