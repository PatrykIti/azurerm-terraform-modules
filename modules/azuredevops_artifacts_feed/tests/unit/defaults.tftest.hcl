# Test default settings for Azure DevOps Artifacts Feed

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_feed.feed) == 0
    error_message = "No feeds should be created by default."
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
