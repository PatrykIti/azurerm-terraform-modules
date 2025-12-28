# Test outputs for Azure DevOps Pipelines

mock_provider "azuredevops" {
  mock_resource "azuredevops_build_definition" {
    defaults = {
      id = "1"
    }
    override_during = plan
  }

  mock_resource "azuredevops_build_folder" {
    defaults = {
      id = "folder-0001"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "pipelines-outputs"
  repository = {
    repo_id   = "00000000-0000-0000-0000-000000000000"
    repo_type = "TfsGit"
    yml_path  = "azure-pipelines.yml"
  }

  build_folders = [
    {
      key  = "pipelines"
      path = "\\Pipelines"
    }
  ]

  pipeline_authorizations = [
    {
      resource_id = "endpoint-0001"
      type        = "endpoint"
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = output.build_definition_id == "1"
    error_message = "build_definition_id should expose the pipeline ID."
  }

  assert {
    condition     = contains(keys(output.build_folder_ids), "pipelines")
    error_message = "build_folder_ids should be keyed by the folder key."
  }

  assert {
    condition     = azuredevops_pipeline_authorization.pipeline_authorization["endpoint:endpoint-0001"].pipeline_id == 1
    error_message = "pipeline_authorizations should default pipeline_id to the module build definition."
  }
}
