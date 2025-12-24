# Test default settings for Azure DevOps Pipelines

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_build_definition.build_definition) == 0
    error_message = "No build definitions should be created by default."
  }

  assert {
    condition     = length(azuredevops_build_folder.build_folder) == 0
    error_message = "No build folders should be created by default."
  }

  assert {
    condition     = length(azuredevops_pipeline_authorization.pipeline_authorization) == 0
    error_message = "No pipeline authorizations should be created by default."
  }
}
