# Test outputs for Azure DevOps Work Items

mock_provider "azuredevops" {
  mock_resource "azuredevops_workitemtrackingprocess_process" {
    defaults = {
      id = "process-0001"
    }
    override_during = plan
  }

  mock_resource "azuredevops_workitem" {
    defaults = {
      id = "workitem-0001"
    }
    override_during = plan
  }

  mock_resource "azuredevops_workitemquery_folder" {
    defaults = {
      id   = "00000000-0000-0000-0000-000000000001"
      path = "Shared Queries/Team"
    }
    override_during = plan
  }

  mock_resource "azuredevops_workitemquery" {
    defaults = {
      id   = "query-0001"
      path = "Shared Queries/Team/Active Issues"
    }
    override_during = plan
  }

  mock_resource "azuredevops_workitemquery_permissions" {
    defaults = {
      id = "query-perm-0001"
    }
    override_during = plan
  }

  mock_resource "azuredevops_area_permissions" {
    defaults = {
      id = "area-perm-0001"
    }
    override_during = plan
  }

  mock_resource "azuredevops_iteration_permissions" {
    defaults = {
      id = "iteration-perm-0001"
    }
    override_during = plan
  }

  mock_resource "azuredevops_tagging_permissions" {
    defaults = {
      id = "tagging-perm-0001"
    }
    override_during = plan
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  title      = "Example"
  type       = "Issue"

  processes = [
    {
      key                    = "custom"
      name                   = "custom-agile"
      parent_process_type_id = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
    }
  ]

  query_folders = [
    {
      key  = "team"
      name = "Team"
      area = "Shared Queries"
    }
  ]

  queries = [
    {
      key        = "active-issues"
      name       = "Active Issues"
      parent_key = "team"
      wiql       = "SELECT [System.Id] FROM WorkItems"
    }
  ]

  query_permissions = [
    {
      key       = "active-issues-readers"
      query_key = "active-issues"
      principal = "descriptor-0001"
      permissions = {
        Read = "Allow"
      }
    }
  ]

  area_permissions = [
    {
      key       = "area-root"
      path      = "/"
      principal = "descriptor-0001"
      permissions = {
        GENERIC_READ = "Allow"
      }
    }
  ]

  iteration_permissions = [
    {
      key       = "iteration-root"
      path      = "/"
      principal = "descriptor-0001"
      permissions = {
        GENERIC_READ = "Allow"
      }
    }
  ]

  tagging_permissions = [
    {
      key       = "tagging-root"
      principal = "descriptor-0001"
      permissions = {
        Enumerate = "allow"
      }
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
    condition     = output.work_item_id != null && output.work_item_id != ""
    error_message = "work_item_id should be populated."
  }

  assert {
    condition     = contains(keys(output.query_folder_ids), "team")
    error_message = "query_folder_ids should include the folder key."
  }

  assert {
    condition     = contains(keys(output.query_ids), "active-issues")
    error_message = "query_ids should include the query key."
  }

  assert {
    condition     = contains(keys(output.query_permission_ids), "active-issues-readers")
    error_message = "query_permission_ids should include the permission key."
  }

  assert {
    condition     = contains(keys(output.area_permission_ids), "area-root")
    error_message = "area_permission_ids should include the permission key."
  }

  assert {
    condition     = contains(keys(output.iteration_permission_ids), "iteration-root")
    error_message = "iteration_permission_ids should include the permission key."
  }

  assert {
    condition     = contains(keys(output.tagging_permission_ids), "tagging-root")
    error_message = "tagging_permission_ids should include the permission key."
  }
}
