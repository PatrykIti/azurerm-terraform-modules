# Test default settings for Azure DevOps Work Items

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_workitem.work_item) == 0
    error_message = "No work items should be created by default."
  }

  assert {
    condition     = length(azuredevops_workitemquery.query) == 0
    error_message = "No work item queries should be created by default."
  }

  assert {
    condition     = length(azuredevops_workitemtrackingprocess_process.process) == 0
    error_message = "No processes should be created by default."
  }
}
