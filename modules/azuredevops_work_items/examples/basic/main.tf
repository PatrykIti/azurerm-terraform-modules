provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

  work_items = [
    {
      title = "Example Work Item"
      type  = "Issue"
      state = "Active"
      tags  = ["terraform"]
    }
  ]
}
