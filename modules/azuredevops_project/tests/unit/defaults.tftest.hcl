# Test default settings for the Azure DevOps Project module

mock_provider "azuredevops" {
  mock_resource "azuredevops_project" {
    defaults = {
      id                  = "00000000-0000-0000-0000-000000000000"
      process_template_id = "11111111-1111-1111-1111-111111111111"
    }
  }
}

variables {
  name = "ado-project-defaults"
}

run "verify_default_project_settings" {
  command = plan

  assert {
    condition     = azuredevops_project.project.visibility == "private"
    error_message = "Default visibility should be private"
  }

  assert {
    condition     = azuredevops_project.project.version_control == "Git"
    error_message = "Default version control should be Git"
  }

  assert {
    condition     = azuredevops_project.project.work_item_template == "Agile"
    error_message = "Default work item template should be Agile"
  }
}

run "verify_optional_resources_disabled" {
  command = plan

  assert {
    condition     = length(azuredevops_project_pipeline_settings.project_pipeline_settings) == 0
    error_message = "pipeline_settings should be disabled by default"
  }

  assert {
    condition     = length(azuredevops_project_tags.project_tags) == 0
    error_message = "project_tags should be disabled by default"
  }

  assert {
    condition     = length(azuredevops_dashboard.dashboard) == 0
    error_message = "dashboards should be disabled by default"
  }
}
