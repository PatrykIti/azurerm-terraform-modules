# Test default settings for Azure DevOps Wiki

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  wiki = {
    name = "core-wiki"
    type = "projectWiki"
  }
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_wiki.wiki.name == "core-wiki"
    error_message = "One wiki should be created."
  }

  assert {
    condition     = length(azuredevops_wiki_page.wiki_page) == 0
    error_message = "No wiki pages should be created by default."
  }
}
