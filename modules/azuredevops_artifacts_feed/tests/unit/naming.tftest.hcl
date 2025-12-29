# Test feed naming

mock_provider "azuredevops" {}

variables {
  name       = "core-feed"
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "feed_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_feed.feed) == 1
    error_message = "A feed should be created when name/project_id are set."
  }

  assert {
    condition     = azuredevops_feed.feed[0].name == "core-feed"
    error_message = "Feed name should match the name variable."
  }
}
