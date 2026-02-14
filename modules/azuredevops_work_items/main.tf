# Azure DevOps Work Items

resource "azuredevops_workitem" "work_item" {
  project_id     = var.project_id
  title          = var.title
  type           = var.type
  state          = var.state
  tags           = var.tags
  area_path      = var.area_path
  iteration_path = var.iteration_path
  parent_id      = var.parent_id
  custom_fields  = var.custom_fields
}
