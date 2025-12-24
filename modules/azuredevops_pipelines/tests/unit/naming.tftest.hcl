# Test build definition naming defaults

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  build_definitions = {
    core = {
      repository = {
        repo_id   = "00000000-0000-0000-0000-000000000000"
        repo_type = "TfsGit"
        yml_path  = "azure-pipelines.yml"
      }
    }
  }
}

run "build_definition_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_build_definition.build_definition) == 1
    error_message = "build_definitions should create one pipeline."
  }

  assert {
    condition     = azuredevops_build_definition.build_definition["core"].name == "core"
    error_message = "Build definition name should default to the map key."
  }
}
