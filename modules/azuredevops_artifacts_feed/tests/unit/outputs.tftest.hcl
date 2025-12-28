# Test outputs for Azure DevOps Artifacts Feed

mock_provider "azuredevops" {
  mock_resource "azuredevops_feed" {
    defaults = {
      id         = "11111111-1111-1111-1111-111111111111"
      name       = "example-feed"
      project_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  name       = "example-feed"
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "outputs_plan" {
  command = apply

  assert {
    condition     = output.feed_id == "11111111-1111-1111-1111-111111111111"
    error_message = "feed_id should expose the feed resource ID."
  }

  assert {
    condition     = output.feed_name == "example-feed"
    error_message = "feed_name should expose the feed resource name."
  }

  assert {
    condition     = output.feed_project_id == "00000000-0000-0000-0000-000000000000"
    error_message = "feed_project_id should expose the feed project ID."
  }

  assert {
    condition     = length(output.feed_permission_ids) == 0
    error_message = "feed_permission_ids should be empty when no permissions are defined."
  }

  assert {
    condition     = length(output.feed_retention_policy_ids) == 0
    error_message = "feed_retention_policy_ids should be empty when no retention policies are defined."
  }
}
