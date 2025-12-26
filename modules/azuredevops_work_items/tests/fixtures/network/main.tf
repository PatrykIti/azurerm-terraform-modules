provider "azuredevops" {}

module "azuredevops_work_items" {
  source = "../../"

  project_id = var.project_id

  work_items = [
    {
      key   = "network-item"
      title = "${var.work_item_title_prefix}-network"
      type  = "Issue"
      state = "Active"
    }
  ]
}
