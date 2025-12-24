# Test extension planning

mock_provider "azuredevops" {}

variables {
  extensions = [
    {
      publisher_id = "publisher-one"
      extension_id = "extension-one"
    }
  ]
}

run "extension_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_extension.extension) == 1
    error_message = "extensions should create one resource."
  }
}
