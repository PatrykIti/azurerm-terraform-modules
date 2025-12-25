# Test outputs for Azure DevOps Work Items

mock_provider "azuredevops" {
  mock_resource "azuredevops_workitemtrackingprocess_process" {
    defaults = {
      id = "process-0001"
    }
  }

  mock_resource "azuredevops_workitem" {
    defaults = {
      id = "workitem-0001"
    }
  }

  mock_resource "azuredevops_workitemquery" {
    defaults = {
      id = "query-0001"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  processes = {
    custom = {
      parent_process_type_id = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
    }
  }

  work_items = [
    {
      title = "Example"
      type  = "Issue"
    }
  ]

  queries = [
    {
      name = "All Issues"
      area = "Shared Queries"
      wiql = "SELECT [System.Id] FROM WorkItems"
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.process_ids)) == 1
    error_message = "process_ids should include configured processes."
  }

  assert {
    condition     = length(keys(output.work_item_ids)) == 1
    error_message = "work_item_ids should include configured work items."
  }

  assert {
    condition     = length(keys(output.query_ids)) == 1
    error_message = "query_ids should include configured queries."
  }
}
