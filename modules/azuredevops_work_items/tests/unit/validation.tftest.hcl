# Test validation for Azure DevOps Work Items

mock_provider "azuredevops" {}

run "invalid_query_folder_selector" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"

    query_folders = [
      {
        name      = "Invalid"
        area      = "Shared Queries"
        parent_id = 1
      }
    ]
  }

  expect_failures = [
    var.query_folders,
  ]
}

run "missing_project_id_for_work_items" {
  command = plan

  variables {
    work_items = [
      {
        key   = "item"
        title = "Missing Project"
        type  = "Issue"
      }
    ]
  }

  expect_failures = [
    var.work_items,
  ]
}

run "duplicate_work_item_keys" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"

    work_items = [
      {
        key   = "dup"
        title = "One"
        type  = "Issue"
      },
      {
        key   = "dup"
        title = "Two"
        type  = "Issue"
      }
    ]
  }

  expect_failures = [
    var.work_items,
  ]
}

run "invalid_parent_combo" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"

    work_items = [
      {
        key        = "child"
        title      = "Child"
        type       = "Issue"
        parent_id  = 1
        parent_key = "parent"
      }
    ]
  }

  expect_failures = [
    var.work_items,
  ]
}

run "invalid_parent_key_reference" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"

    work_items = [
      {
        key        = "child"
        title      = "Child"
        type       = "Issue"
        parent_key = "missing"
      }
    ]
  }

  expect_failures = [
    var.work_items,
  ]
}

run "duplicate_query_folder_keys" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"

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

run "invalid_query_parent_key_reference" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"

    queries = [
      {
        key        = "active-issues"
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
    project_id = "00000000-0000-0000-0000-000000000000"

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
    project_id = "00000000-0000-0000-0000-000000000000"

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

run "missing_project_id_for_area_permissions" {
  command = plan

  variables {
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
  }

  expect_failures = [
    var.area_permissions,
  ]
}
