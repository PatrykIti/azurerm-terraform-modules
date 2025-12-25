# Test validation for Azure DevOps Wiki

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_page" {
  command = plan

  variables {
    wikis = {
      project = {
        type = "projectWiki"
      }
    }

    wiki_pages = [
      {
        path    = "/Invalid"
        content = "Missing wiki reference"
      }
    ]
  }

  expect_failures = [
    var.wiki_pages,
  ]
}
