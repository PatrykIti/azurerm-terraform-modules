# Test validation for Azure DevOps Work Items

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  title      = "Validation Work Item"
  type       = "Task"
}

run "invalid_parent_id" {
  command = plan

  variables {
    parent_id = 0
  }

  expect_failures = [
    var.parent_id,
  ]
}

run "missing_project_id_for_work_item" {
  command = plan

  variables {
    project_id = null
  }

  expect_failures = [
    azuredevops_workitem.work_item,
  ]
}

run "duplicate_process_keys" {
  command = plan

  variables {
    processes = [
      {
        name                   = "custom-agile"
        parent_process_type_id = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
      },
      {
        name                   = "custom-agile"
        parent_process_type_id = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
      }
    ]
  }

  expect_failures = [
    var.processes,
  ]
}

run "duplicate_query_folder_keys" {
  command = plan

  variables {
    query_folders = [
      {
        name = "Shared"
        area = "Shared Queries"
      },
      {
        name = "Shared"
        area = "Shared Queries"
      }
    ]
  }

  expect_failures = [
    var.query_folders,
  ]
}

run "duplicate_query_keys" {
  command = plan

  variables {
    queries = [
      {
        name = "Active Issues"
        area = "Shared Queries"
        wiql = "SELECT [System.Id] FROM WorkItems"
      },
      {
        name = "Active Issues"
        area = "Shared Queries"
        wiql = "SELECT [System.Id] FROM WorkItems"
      }
    ]
  }

  expect_failures = [
    var.queries,
  ]
}

run "invalid_query_parent_key_reference" {
  command = plan

  variables {
    queries = [
      {
        name       = "Active Issues"
        parent_key = "missing"
        wiql       = "SELECT [System.Id] FROM WorkItems"
      }
    ]
  }

  expect_failures = [
    var.queries,
  ]
}

run "invalid_query_permission_selector" {
  command = plan

  variables {
    queries = [
      {
        key  = "active-issues"
        name = "Active Issues"
        area = "Shared Queries"
        wiql = "SELECT [System.Id] FROM WorkItems"
      }
    ]

    query_permissions = [
      {
        principal = "descriptor-0001"
        path      = "Shared Queries"
        query_key = "active-issues"
        permissions = {
          Read = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.query_permissions,
  ]
}

run "missing_query_permission_selector" {
  command = plan

  variables {
    query_permissions = [
      {
        principal = "descriptor-0001"
        permissions = {
          Read = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.query_permissions,
  ]
}

run "duplicate_query_permission_keys" {
  command = plan

  variables {
    query_permissions = [
      {
        principal = "descriptor-0001"
        path      = "Shared Queries"
        permissions = {
          Read = "Allow"
        }
      },
      {
        principal = "descriptor-0001"
        path      = "Shared Queries"
        permissions = {
          Read = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.query_permissions,
  ]
}

run "duplicate_area_permission_keys" {
  command = plan

  variables {
    area_permissions = [
      {
        path      = "/"
        principal = "descriptor-0001"
        permissions = {
          GENERIC_READ = "Allow"
        }
      },
      {
        path      = "/"
        principal = "descriptor-0001"
        permissions = {
          GENERIC_READ = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.area_permissions,
  ]
}

run "duplicate_iteration_permission_keys" {
  command = plan

  variables {
    iteration_permissions = [
      {
        path      = "/"
        principal = "descriptor-0001"
        permissions = {
          GENERIC_READ = "Allow"
        }
      },
      {
        path      = "/"
        principal = "descriptor-0001"
        permissions = {
          GENERIC_READ = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.iteration_permissions,
  ]
}

run "duplicate_tagging_permission_keys" {
  command = plan

  variables {
    tagging_permissions = [
      {
        principal = "descriptor-0001"
        permissions = {
          Enumerate = "allow"
        }
      },
      {
        principal = "descriptor-0001"
        permissions = {
          Enumerate = "allow"
        }
      }
    ]
  }

  expect_failures = [
    var.tagging_permissions,
  ]
}
