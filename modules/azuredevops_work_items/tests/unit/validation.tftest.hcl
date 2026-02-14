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

run "invalid_project_id_empty" {
  command = plan

  variables {
    project_id = ""
  }

  expect_failures = [
    var.project_id,
  ]
}

run "invalid_title_empty" {
  command = plan

  variables {
    title = ""
  }

  expect_failures = [
    var.title,
  ]
}

run "invalid_type_empty" {
  command = plan

  variables {
    type = ""
  }

  expect_failures = [
    var.type,
  ]
}

run "invalid_custom_fields_empty_value" {
  command = plan

  variables {
    custom_fields = {
      "System.Description" = ""
    }
  }

  expect_failures = [
    var.custom_fields,
  ]
}
