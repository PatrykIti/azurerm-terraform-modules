# Test build definition naming and normalization

mock_provider "azuredevops" {}

variables {
  project_id   = "00000000-0000-0000-0000-000000000000"
  name         = "pipeline-core"
  path         = "\\Pipelines"
  queue_status = "PAUSED"
  repository = {
    repo_id   = "00000000-0000-0000-0000-000000000000"
    repo_type = "TfsGit"
    yml_path  = "azure-pipelines.yml"
  }
}

run "build_definition_plan" {
  command = plan

  assert {
    condition     = azuredevops_build_definition.build_definition.name == "pipeline-core"
    error_message = "Build definition name should match the input name."
  }

  assert {
    condition     = azuredevops_build_definition.build_definition.path == "\\Pipelines"
    error_message = "Build definition path should match the input path."
  }

  assert {
    condition     = azuredevops_build_definition.build_definition.queue_status == "paused"
    error_message = "Queue status should be normalized to lowercase."
  }
}
