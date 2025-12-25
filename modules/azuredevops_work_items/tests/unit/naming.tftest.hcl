# Test process naming defaults

mock_provider "azuredevops" {}

variables {
  processes = {
    custom = {
      parent_process_type_id = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
    }
  }
}

run "process_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_workitemtrackingprocess_process.process) == 1
    error_message = "processes should create one process."
  }

  assert {
    condition     = azuredevops_workitemtrackingprocess_process.process["custom"].name == "custom"
    error_message = "Process name should default to the map key."
  }
}
