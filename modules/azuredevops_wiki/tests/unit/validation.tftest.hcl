# Test validation for Azure DevOps Wiki

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  wiki = {
    name = "project"
    type = "projectWiki"
  }
}

run "invalid_wiki_type" {
  command = plan

  variables {
    wiki = {
      name = "project"
      type = "unsupported"
    }
  }

  expect_failures = [
    var.wiki,
  ]
}

run "invalid_page_path" {
  command = plan

  variables {
    wiki_pages = {
      home = {
        path    = " "
        content = "content"
      }
    }
  }

  expect_failures = [
    var.wiki_pages,
  ]
}

run "duplicate_page_paths" {
  command = plan

  variables {
    wiki_pages = {
      page_a = {
        path    = "/Home"
        content = "A"
      }
      page_b = {
        path    = "/Home"
        content = "B"
      }
    }
  }

  expect_failures = [
    var.wiki_pages,
  ]
}
