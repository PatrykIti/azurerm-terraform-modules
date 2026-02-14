# Test outputs for Azure DevOps Wiki

mock_provider "azuredevops" {
  mock_resource "azuredevops_wiki" {
    defaults = {
      id         = "11111111-1111-1111-1111-111111111111"
      name       = "core"
      remote_url = "https://dev.azure.com/org/project/_wiki/wikis/11111111-1111-1111-1111-111111111111"
      url        = "https://dev.azure.com/org/_apis/wiki/wikis/11111111-1111-1111-1111-111111111111"
    }
  }

  mock_resource "azuredevops_wiki_page" {
    defaults = {
      id = "page-0001"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  wiki = {
    name = "core"
    type = "projectWiki"
  }

  wiki_pages = {
    home = {
      path    = "/Home"
      content = "Home"
    }
  }
}

run "outputs_plan" {
  command = apply

  assert {
    condition     = output.wiki_id == "11111111-1111-1111-1111-111111111111"
    error_message = "wiki_id should return the created wiki ID."
  }

  assert {
    condition     = output.wiki_name == "core"
    error_message = "wiki_name should return the created wiki name."
  }

  assert {
    condition     = length(keys(output.wiki_page_ids)) == 1
    error_message = "wiki_page_ids should include configured pages."
  }
}
