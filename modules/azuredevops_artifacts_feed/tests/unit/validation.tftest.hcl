# Test variable validation for Azure DevOps Artifacts Feed

mock_provider "azuredevops" {}

run "invalid_feed_permission" {
  command = plan

  variables {
    feeds = {
      example = {}
    }

    feed_permissions = [
      {
        feed_id            = "00000000-0000-0000-0000-000000000000"
        feed_key           = "example"
        identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
        role               = "reader"
      }
    ]
  }

  expect_failures = [
    var.feed_permissions,
  ]
}
