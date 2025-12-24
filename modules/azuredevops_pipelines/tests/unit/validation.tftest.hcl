# Test variable validation for Azure DevOps Pipelines

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_pipeline_authorization" {
  command = plan

  variables {
    pipeline_authorizations = [
      {
        resource_id  = "00000000-0000-0000-0000-000000000000"
        type         = "endpoint"
        pipeline_id  = "1"
        pipeline_key = "main"
      }
    ]
  }

  expect_failures = [
    var.pipeline_authorizations,
  ]
}
