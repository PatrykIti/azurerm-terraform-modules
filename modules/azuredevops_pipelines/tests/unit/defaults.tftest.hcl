# Test default settings for Azure DevOps Pipelines

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "pipelines-defaults"
  repository = {
    repo_id   = "00000000-0000-0000-0000-000000000000"
    repo_type = "TfsGit"
    yml_path  = "azure-pipelines.yml"
  }
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_build_definition.build_definition.name == "pipelines-defaults"
    error_message = "Build definition name should match the input name."
  }

  assert {
    condition     = length(azuredevops_build_definition_permissions.build_definition_permissions) == 0
    error_message = "No build definition permissions should be created by default."
  }

  assert {
    condition     = length(azuredevops_pipeline_authorization.pipeline_authorization) == 0
    error_message = "No pipeline authorizations should be created by default."
  }
}
