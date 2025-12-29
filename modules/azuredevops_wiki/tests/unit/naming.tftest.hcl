# Test wiki naming defaults

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  wikis = {
    core = {
      type = "projectWiki"
    }
  }
}

run "wiki_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_wiki.wiki) == 1
    error_message = "wikis should create one wiki."
  }

  assert {
    condition     = azuredevops_wiki.wiki["core"].name == "core"
    error_message = "Wiki name should default to the map key."
  }
}
