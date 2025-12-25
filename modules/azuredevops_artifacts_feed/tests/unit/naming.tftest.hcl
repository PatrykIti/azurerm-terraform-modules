# Test feed naming defaults

mock_provider "azuredevops" {}

variables {
  feeds = {
    core = {}
  }
}

run "feed_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_feed.feed) == 1
    error_message = "feeds should create one feed."
  }

  assert {
    condition     = azuredevops_feed.feed["core"].name == "core"
    error_message = "Feed name should default to the map key."
  }
}
