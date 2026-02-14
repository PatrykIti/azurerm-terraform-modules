# Test work item naming and field propagation

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  title      = "Naming Work Item"
  type       = "Task"
  state      = "Active"
}

run "work_item_plan" {
  command = plan

  assert {
    condition     = azuredevops_workitem.work_item.title == "Naming Work Item"
    error_message = "Work item title should match the input."
  }

  assert {
    condition     = azuredevops_workitem.work_item.state == "Active"
    error_message = "Work item state should match the input."
  }
}
