# Test variable validation for Azure DevOps Variable Groups

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_variable_value" {
  command = plan

  variables {
    variable_groups = {
      invalid = {
        allow_access = true
        variables = [
          {
            name         = "bad"
            value        = "value"
            secret_value = "secret"
            is_secret    = true
          }
        ]
      }
    }
  }

  expect_failures = [
    var.variable_groups,
  ]
}
