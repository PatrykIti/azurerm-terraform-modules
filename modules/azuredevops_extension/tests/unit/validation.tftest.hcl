# Test variable validation for Azure DevOps Extension

mock_provider "azuredevops" {}

run "empty_publisher_id" {
  command = plan

  variables {
    publisher_id = ""
    extension_id = "extension-one"
  }

  expect_failures = [
    var.publisher_id,
  ]
}

run "empty_extension_id" {
  command = plan

  variables {
    publisher_id = "publisher-one"
    extension_id = ""
  }

  expect_failures = [
    var.extension_id,
  ]
}

run "empty_extension_version" {
  command = plan

  variables {
    publisher_id      = "publisher-one"
    extension_id      = "extension-one"
    extension_version = " "
  }

  expect_failures = [
    var.extension_version,
  ]
}
