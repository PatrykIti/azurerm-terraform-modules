provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

  work_items = [
    {
      title = "${var.work_item_title_prefix}-basic"
      type  = "Issue"
      state = "Active"
    }
  ]
}
