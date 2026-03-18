# Test default settings for Azure DevOps Work Items

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  title      = "Default Work Item"
  type       = "Task"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_workitem.work_item.title == var.title
    error_message = "Work item should be created with the provided title."
  }

  assert {
    condition     = azuredevops_workitem.work_item.project_id == var.project_id
    error_message = "Work item should use the module project_id."
  }

  assert {
    condition     = azuredevops_workitem.work_item.type == var.type
    error_message = "Work item type should match the provided type."
  }
}
