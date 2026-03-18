# Test outputs for Azure DevOps Work Items

mock_provider "azuredevops" {
  mock_resource "azuredevops_workitem" {
    defaults = {
      id = "workitem-0001"
    }
    override_during = plan
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  title      = "Example"
  type       = "Issue"
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = output.work_item_id == "workitem-0001"
    error_message = "work_item_id should be populated from the created work item."
  }
}
