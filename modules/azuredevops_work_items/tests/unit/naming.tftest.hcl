# Test process naming defaults

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  title      = "Naming Work Item"
  type       = "Task"

  processes = [
    {
      name                   = "custom-agile"
      parent_process_type_id = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
    }
  ]
}

run "process_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_workitemtrackingprocess_process.process) == 1
    error_message = "processes should create one process."
  }

  assert {
    condition     = azuredevops_workitemtrackingprocess_process.process["custom-agile"].name == "custom-agile"
    error_message = "Process key should default to the process name when key is omitted."
  }
}
