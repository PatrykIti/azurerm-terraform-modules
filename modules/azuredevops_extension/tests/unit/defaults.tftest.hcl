# Test default settings for Azure DevOps Extension

mock_provider "azuredevops" {}

variables {
  publisher_id = "publisher-defaults"
  extension_id = "extension-defaults"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = var.version == null
    error_message = "version should default to null."
  }
}
