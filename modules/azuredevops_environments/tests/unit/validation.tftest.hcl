# Test variable validation for Azure DevOps Environments

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_environment_selector" {
  command = plan

  variables {
    kubernetes_resources = [
      {
        environment_id    = "00000000-0000-0000-0000-000000000000"
        environment_key   = "dev"
        service_endpoint_id = "00000000-0000-0000-0000-000000000000"
        name              = "dev-k8s"
        namespace         = "default"
      }
    ]
  }

  expect_failures = [
    var.kubernetes_resources,
  ]
}
