# Test elastic pool naming

mock_provider "azuredevops" {}

variables {
  name                   = "elastic-pool"
  service_endpoint_id    = "00000000-0000-0000-0000-000000000001"
  service_endpoint_scope = "00000000-0000-0000-0000-000000000000"
  azure_resource_id      = "resource-0001"
}

run "elastic_pool_plan" {
  command = plan

  assert {
    condition     = azuredevops_elastic_pool.elastic_pool.name == "elastic-pool"
    error_message = "Elastic pool name should match the input."
  }
}
