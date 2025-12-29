# Test extension planning

mock_provider "azuredevops" {}

variables {
  publisher_id = "publisher-one"
  extension_id = "extension-one"
}

run "extension_plan" {
  command = plan

  assert {
    condition     = azuredevops_extension.extension.publisher_id == var.publisher_id
    error_message = "publisher_id should match the configured value."
  }

  assert {
    condition     = azuredevops_extension.extension.extension_id == var.extension_id
    error_message = "extension_id should match the configured value."
  }
}
