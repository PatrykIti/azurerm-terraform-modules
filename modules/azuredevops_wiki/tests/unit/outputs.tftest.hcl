# Test outputs for Azure DevOps Wiki

mock_provider "azuredevops" {
  mock_resource "azuredevops_wiki" {
    defaults = {
      id         = "wiki-0001"
      remote_url = "https://dev.azure.com/org/project/_wiki/wikis/wiki-0001"
      url        = "https://dev.azure.com/org/_apis/wiki/wikis/wiki-0001"
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

  wikis = {
    project = {
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      wiki_key = "project"
      path     = "/Home"
      content  = "Home"
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.wiki_ids)) == 1
    error_message = "wiki_ids should include configured wikis."
  }

  assert {
    condition     = length(keys(output.wiki_remote_urls)) == 1
    error_message = "wiki_remote_urls should include configured wikis."
  }

  assert {
    condition     = length(keys(output.wiki_urls)) == 1
    error_message = "wiki_urls should include configured wikis."
  }

  assert {
    condition     = length(keys(output.wiki_page_ids)) == 1
    error_message = "wiki_page_ids should include configured pages."
  }
}
