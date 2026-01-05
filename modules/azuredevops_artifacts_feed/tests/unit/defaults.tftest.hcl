# Test default settings for Azure DevOps Artifacts Feed

mock_provider "azuredevops" {}

variables {
  name       = "example-feed"
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_feed.feed.name == "example-feed"
    error_message = "Feed name should default to the provided name."
  }

  assert {
    condition     = length(azuredevops_feed_permission.feed_permission) == 0
    error_message = "No feed permissions should be created by default."
  }

  assert {
    condition     = length(azuredevops_feed_retention_policy.feed_retention_policy) == 0
    error_message = "No feed retention policies should be created by default."
  }
}
