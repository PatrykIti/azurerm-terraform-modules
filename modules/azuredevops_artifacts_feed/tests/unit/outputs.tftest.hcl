# Test outputs for Azure DevOps Artifacts Feed

mock_provider "azuredevops" {
  mock_resource "azuredevops_feed" {
    defaults = {
      id         = "feed-0001"
      name       = "example"
      project_id = "project-0001"
    }
  }
}

variables {
  feeds = {
    example = {}
  }
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.feed_ids)) == 1
    error_message = "feed_ids should include configured feeds."
  }

  assert {
    condition     = length(keys(output.feed_names)) == 1
    error_message = "feed_names should include configured feeds."
  }

  assert {
    condition     = length(keys(output.feed_project_ids)) == 1
    error_message = "feed_project_ids should include configured feeds."
  }
}
