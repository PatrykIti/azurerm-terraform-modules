# Test outputs for Azure DevOps Pipelines

mock_provider "azuredevops" {
  mock_resource "azuredevops_build_definition" {
    defaults = {
      id = "pipeline-0001"
    }
  }

  mock_resource "azuredevops_build_folder" {
    defaults = {
      id = "folder-0001"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  build_folders = [
    {
      path = "\\Pipelines"
    }
  ]

  build_definitions = {
    main = {
      repository = {
        repo_id   = "00000000-0000-0000-0000-000000000000"
        repo_type = "TfsGit"
        yml_path  = "azure-pipelines.yml"
      }
    }
  }
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.build_definition_ids)) == 1
    error_message = "build_definition_ids should include configured pipelines."
  }

  assert {
    condition     = length(keys(output.build_folder_ids)) == 1
    error_message = "build_folder_ids should include configured folders."
  }
}
