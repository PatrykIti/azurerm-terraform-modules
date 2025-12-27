# Test variable validation for Azure DevOps Pipelines

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  build_definitions = {
    core = {
      repository = {
        repo_id   = "00000000-0000-0000-0000-000000000000"
        repo_type = "TfsGit"
        yml_path  = "azure-pipelines.yml"
      }
    }
  }
}

run "invalid_pipeline_authorization_both_ids" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        resource_id  = "00000000-0000-0000-0000-000000000000"
        type         = "endpoint"
        pipeline_id  = "1"
        pipeline_key = "core"
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}

run "invalid_pipeline_authorization_missing_id" {
  command = plan

  variables {
    pipeline_authorizations = [
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

run "invalid_pipeline_authorization_type" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        resource_id  = "00000000-0000-0000-0000-000000000000"
        type         = "invalid"
        pipeline_key = "core"
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}

run "invalid_pipeline_authorization_unknown_key" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        resource_id  = "00000000-0000-0000-0000-000000000000"
        type         = "endpoint"
        pipeline_key = "missing"
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}

run "invalid_resource_authorization_missing_definition" {
  command = plan

  variables {
    resource_authorizations = [
      {
        resource_id = "00000000-0000-0000-0000-000000000000"
        authorized  = true
        type        = "endpoint"
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

run "invalid_resource_authorization_unknown_key" {
  command = plan

  variables {
    resource_authorizations = [
      {
        resource_id          = "00000000-0000-0000-0000-000000000000"
        authorized           = true
        type                 = "endpoint"
        build_definition_key = "missing"
      }
    ]
  }

  expect_failures = [
    var.resource_authorizations,
  ]
}

run "invalid_build_definition_permission_unknown_key" {
  command = plan

  variables {
    build_definition_permissions = [
      {
        build_definition_key = "missing"
        principal            = "00000000-0000-0000-0000-000000000000"
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
        build_definition_key = "core"
        principal            = "00000000-0000-0000-0000-000000000000"
        permissions = {
          ViewBuildDefinition = "Allow"
        }
      },
      {
        build_definition_key = "core"
        principal            = "00000000-0000-0000-0000-000000000000"
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
        resource_id  = "00000000-0000-0000-0000-000000000000"
        type         = "endpoint"
        pipeline_key = "core"
      },
      {
        resource_id  = "00000000-0000-0000-0000-000000000000"
        type         = "endpoint"
        pipeline_key = "core"
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
        definition_id = "123"
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
        key                  = ""
        build_definition_key = "core"
        principal            = "00000000-0000-0000-0000-000000000000"
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

run "invalid_pipeline_authorization_resource_id_empty" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        resource_id  = ""
        type         = "endpoint"
        pipeline_key = "core"
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}

run "invalid_pipeline_authorization_key_empty" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        key          = ""
        resource_id  = "00000000-0000-0000-0000-000000000000"
        type         = "endpoint"
        pipeline_key = "core"
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
    build_definitions = {
      main = {
        repository = {
          repo_id   = "00000000-0000-0000-0000-000000000000"
          repo_type = "TfsGit"
          yml_path  = "azure-pipelines.yml"
        }
        build_completion_trigger = {
          build_definition_id = ""
          branch_filter = {
            include = ["main"]
          }
        }
      }
    }
  }

  expect_failures = [
    var.build_definitions,
  ]
}
