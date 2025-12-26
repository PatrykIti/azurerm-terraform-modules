# Test variable validation for Azure DevOps Variable Groups

mock_provider "azuredevops" {}

run "invalid_variable_value_and_secret" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"
    name       = "invalid-vars"

    variables = [
      {
        name         = "bad"
        value        = "value"
        secret_value = "secret"
        is_secret    = true
      }
    ]
  }

  expect_failures = [
    var.variables,
  ]
}

run "invalid_variable_name" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"
    name       = "invalid-name"

    variables = [
      {
        name  = ""
        value = "value"
      }
    ]
  }

  expect_failures = [
    var.variables,
  ]
}

run "secret_value_requires_is_secret" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"
    name       = "secret-vars"

    variables = [
      {
        name         = "secret"
        secret_value = "secret"
        is_secret    = false
      }
    ]
  }

  expect_failures = [
    var.variables,
  ]
}

run "missing_secret_value_when_is_secret_true" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"
    name       = "missing-secret"

    variables = [
      {
        name      = "secret"
        value     = "value"
        is_secret = true
      }
    ]
  }

  expect_failures = [
    var.variables,
  ]
}

run "invalid_key_vault_required_fields" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"
    name       = "kv-invalid"

    variables = [
      {
        name  = "key"
        value = "value"
      }
    ]

    key_vault = {
      name                = ""
      service_endpoint_id = ""
    }
  }

  expect_failures = [
    var.key_vault,
  ]
}

run "invalid_key_vault_search_depth" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"
    name       = "kv-depth"

    variables = [
      {
        name  = "key"
        value = "value"
      }
    ]

    key_vault = {
      name                = "shared-kv"
      service_endpoint_id = "endpoint-id"
      search_depth        = -1
    }
  }

  expect_failures = [
    var.key_vault,
  ]
}

run "duplicate_variable_group_permission_keys" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"
    name       = "perm-dup"

    variables = [
      {
        name  = "key"
        value = "value"
      }
    ]

    variable_group_permissions = [
      {
        key       = "dup"
        principal = "user-1"
        permissions = {
          View = "allow"
        }
      },
      {
        key       = "dup"
        principal = "user-2"
        permissions = {
          View = "allow"
        }
      }
    ]
  }

  expect_failures = [
    var.variable_group_permissions,
  ]
}

run "duplicate_library_permission_keys" {
  command = plan

  variables {
    project_id = "00000000-0000-0000-0000-000000000000"
    name       = "library-dup"

    variables = [
      {
        name  = "key"
        value = "value"
      }
    ]

    library_permissions = [
      {
        key       = "dup"
        principal = "user-1"
        permissions = {
          View = "allow"
        }
      },
      {
        key       = "dup"
        principal = "user-2"
        permissions = {
          View = "allow"
        }
      }
    ]
  }

  expect_failures = [
    var.library_permissions,
  ]
}
