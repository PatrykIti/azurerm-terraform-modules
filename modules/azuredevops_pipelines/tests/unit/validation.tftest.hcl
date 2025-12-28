# Test variable validation for Azure DevOps Pipelines

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "pipeline-validation"
  repository = {
    repo_id   = "00000000-0000-0000-0000-000000000000"
    repo_type = "TfsGit"
    yml_path  = "azure-pipelines.yml"
  }
}

run "invalid_pipeline_authorization_pipeline_id_empty" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        resource_id = "00000000-0000-0000-0000-000000000000"
        type        = "endpoint"
        pipeline_id = ""
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}

run "invalid_pipeline_authorization_type" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        resource_id = "00000000-0000-0000-0000-000000000000"
        type        = "invalid"
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}

run "invalid_pipeline_authorization_resource_id_empty" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        resource_id = ""
        type        = "endpoint"
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}

run "invalid_build_definition_permission_empty_id" {
  command = plan

  variables {
    build_definition_permissions = [
      {
        build_definition_id = ""
        principal           = "00000000-0000-0000-0000-000000000000"
        permissions = {
          ViewBuildDefinition = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.build_definition_permissions,
  ]
}

run "invalid_resource_authorization_definition_id_empty" {
  command = plan

  variables {
    resource_authorizations = [
      {
        resource_id   = "00000000-0000-0000-0000-000000000000"
        authorized    = true
        type          = "endpoint"
        definition_id = ""
      }
    ]
  }

  expect_failures = [
    var.resource_authorizations,
  ]
}

run "invalid_resource_authorization_type" {
  command = plan

  variables {
    resource_authorizations = [
      {
        resource_id   = "00000000-0000-0000-0000-000000000000"
        authorized    = true
        type          = "invalid"
        definition_id = "123"
      }
    ]
  }

  expect_failures = [
    var.resource_authorizations,
  ]
}

run "invalid_resource_authorization_authorized_false" {
  command = plan

  variables {
    resource_authorizations = [
      {
        resource_id   = "00000000-0000-0000-0000-000000000000"
        authorized    = false
        type          = "endpoint"
        definition_id = "123"
      }
    ]
  }

  expect_failures = [
    var.resource_authorizations,
  ]
}

run "duplicate_build_folder_keys" {
  command = plan

  variables {
    build_folders = [
      {
        path = "\\Pipelines"
      },
      {
        path = "\\Pipelines"
      }
    ]
  }

  expect_failures = [
    var.build_folders,
  ]
}

run "duplicate_build_definition_permission_keys" {
  command = plan

  variables {
    build_definition_permissions = [
      {
        principal = "00000000-0000-0000-0000-000000000000"
        permissions = {
          ViewBuildDefinition = "Allow"
        }
      },
      {
        principal = "00000000-0000-0000-0000-000000000000"
        permissions = {
          ViewBuildDefinition = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.build_definition_permissions,
  ]
}

run "duplicate_build_folder_permission_keys" {
  command = plan

  variables {
    build_folder_permissions = [
      {
        path      = "\\Pipelines"
        principal = "00000000-0000-0000-0000-000000000000"
        permissions = {
          ViewBuildDefinition = "Allow"
        }
      },
      {
        path      = "\\Pipelines"
        principal = "00000000-0000-0000-0000-000000000000"
        permissions = {
          ViewBuildDefinition = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.build_folder_permissions,
  ]
}

run "duplicate_pipeline_authorization_keys" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        resource_id = "00000000-0000-0000-0000-000000000000"
        type        = "endpoint"
      },
      {
        resource_id = "00000000-0000-0000-0000-000000000000"
        type        = "endpoint"
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}

run "duplicate_resource_authorization_keys" {
  command = plan

  variables {
    resource_authorizations = [
      {
        resource_id   = "00000000-0000-0000-0000-000000000000"
        authorized    = true
        type          = "endpoint"
        definition_id = "123"
      },
      {
        resource_id   = "00000000-0000-0000-0000-000000000000"
        authorized    = true
        type          = "endpoint"
        definition_id = "456"
      }
    ]
  }

  expect_failures = [
    var.resource_authorizations,
  ]
}

run "invalid_build_folder_key_empty" {
  command = plan

  variables {
    build_folders = [
      {
        key  = ""
        path = "\\Pipelines"
      }
    ]
  }

  expect_failures = [
    var.build_folders,
  ]
}

run "invalid_build_definition_permission_key_empty" {
  command = plan

  variables {
    build_definition_permissions = [
      {
        key       = ""
        principal = "00000000-0000-0000-0000-000000000000"
        permissions = {
          ViewBuildDefinition = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.build_definition_permissions,
  ]
}

run "invalid_build_folder_permission_key_empty" {
  command = plan

  variables {
    build_folder_permissions = [
      {
        key       = ""
        path      = "\\Pipelines"
        principal = "00000000-0000-0000-0000-000000000000"
        permissions = {
          ViewBuildDefinition = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.build_folder_permissions,
  ]
}

run "invalid_pipeline_authorization_key_empty" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        key         = ""
        resource_id = "00000000-0000-0000-0000-000000000000"
        type        = "endpoint"
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}

run "invalid_resource_authorization_resource_id_empty" {
  command = plan

  variables {
    resource_authorizations = [
      {
        resource_id   = ""
        authorized    = true
        type          = "endpoint"
        definition_id = "123"
      }
    ]
  }

  expect_failures = [
    var.resource_authorizations,
  ]
}

run "invalid_resource_authorization_key_empty" {
  command = plan

  variables {
    resource_authorizations = [
      {
        key           = ""
        resource_id   = "00000000-0000-0000-0000-000000000000"
        authorized    = true
        type          = "endpoint"
        definition_id = "123"
      }
    ]
  }

  expect_failures = [
    var.resource_authorizations,
  ]
}

run "invalid_build_completion_trigger_empty_id" {
  command = plan

  variables {
    build_completion_trigger = {
      build_definition_id = ""
      branch_filter = {
        include = ["main"]
      }
    }
  }

  expect_failures = [
    var.build_completion_trigger,
  ]
}
