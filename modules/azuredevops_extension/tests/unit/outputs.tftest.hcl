# Test outputs for Azure DevOps Extension

mock_provider "azuredevops" {
  mock_resource "azuredevops_extension" {
    defaults = {
      id = "extension-0001"
    }
  }
}

variables {
  extensions = [
    {
      publisher_id = "publisher-one"
      extension_id = "extension-one"
    },
    {
      publisher_id = "publisher-two"
      extension_id = "extension-two"
      version      = "1.2.3"
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.extension_ids)) == 2
    error_message = "extension_ids should include all configured extensions."
  }
}
