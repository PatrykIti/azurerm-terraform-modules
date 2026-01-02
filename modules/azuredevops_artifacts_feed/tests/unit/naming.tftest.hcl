# Test feed naming

mock_provider "azuredevops" {}

variables {
  name       = "core-feed"
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "feed_plan" {
  command = plan

  assert {
    condition     = azuredevops_feed.feed.name == "core-feed"
    error_message = "Feed name should match the name variable."
  }
}
