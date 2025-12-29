# Test outputs for Azure DevOps Extension

mock_provider "azuredevops" {
  mock_resource "azuredevops_extension" {
    defaults = {
      id = "extension-0001"
    }
  }
}

variables {
  publisher_id = "publisher-one"
  extension_id = "extension-one"
}

run "outputs_apply" {
  command = apply

  override_resource {
    target = azuredevops_extension.extension
    values = {
      id = "extension-0001"
    }
  }

  assert {
    condition     = output.extension_id == "extension-0001"
    error_message = "extension_id should be exposed as a string output."
  }
}
