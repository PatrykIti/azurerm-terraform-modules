# Test wiki naming values

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  wiki = {
    name = "core"
    type = "projectWiki"
  }
}

run "wiki_plan" {
  command = plan

  assert {
    condition     = azuredevops_wiki.wiki.name == "core"
    error_message = "Wiki name should match the configured name."
  }
}
