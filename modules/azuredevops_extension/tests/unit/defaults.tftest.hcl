# Test default settings for Azure DevOps Extension

mock_provider "azuredevops" {}

variables {
  publisher_id = "publisher-defaults"
  extension_id = "extension-defaults"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = var.extension_version == null
    error_message = "extension_version should default to null."
  }
}
