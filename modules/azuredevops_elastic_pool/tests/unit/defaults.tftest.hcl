# Test default settings for Azure DevOps Elastic Pool

mock_provider "azuredevops" {}

variables {
  name                   = "Elastic Pool"
  service_endpoint_id    = "00000000-0000-0000-0000-000000000001"
  service_endpoint_scope = "00000000-0000-0000-0000-000000000000"
  azure_resource_id      = "resource-0001"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_elastic_pool.elastic_pool.name == "Elastic Pool"
    error_message = "Elastic pool name should match the input."
  }

  assert {
    condition     = azuredevops_elastic_pool.elastic_pool.desired_idle == 1
    error_message = "desired_idle should default to 1."
  }

  assert {
    condition     = azuredevops_elastic_pool.elastic_pool.max_capacity == 2
    error_message = "max_capacity should default to 2."
  }
}
