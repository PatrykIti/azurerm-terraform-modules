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
    condition     = length(azuredevops_workitemquery.query) == 0
    error_message = "No work item queries should be created by default."
  }

  assert {
    condition     = length(azuredevops_workitemquery_folder.query_folder) == 0
    error_message = "No query folders should be created by default."
  }

  assert {
    condition     = length(azuredevops_workitemquery_folder.query_folder_child) == 0
    error_message = "No child query folders should be created by default."
  }

  assert {
    condition     = length(azuredevops_workitemquery_permissions.query_permissions) == 0
    error_message = "No query permissions should be created by default."
  }

  assert {
    condition     = length(azuredevops_workitemtrackingprocess_process.process) == 0
    error_message = "No processes should be created by default."
  }

  assert {
    condition     = length(azuredevops_area_permissions.area_permissions) == 0
    error_message = "No area permissions should be created by default."
  }

  assert {
    condition     = length(azuredevops_iteration_permissions.iteration_permissions) == 0
    error_message = "No iteration permissions should be created by default."
  }

  assert {
    condition     = length(azuredevops_tagging_permissions.tagging_permissions) == 0
    error_message = "No tagging permissions should be created by default."
  }
}
