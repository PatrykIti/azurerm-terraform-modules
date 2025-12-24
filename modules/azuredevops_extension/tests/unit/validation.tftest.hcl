# Test variable validation for Azure DevOps Extension

mock_provider "azuredevops" {}

run "missing_extension_fields" {
  command = plan

  variables {
    extensions = [
      {
        publisher_id = ""
        extension_id = "extension-one"
      }
    ]
  }

  expect_failures = [
    var.extensions,
  ]
}

run "duplicate_extensions" {
  command = plan

  variables {
    extensions = [
      {
        publisher_id = "publisher-one"
        extension_id = "extension-one"
      },
      {
        publisher_id = "publisher-one"
        extension_id = "extension-one"
      }
    ]
  }

  expect_failures = [
    var.extensions,
  ]
}
