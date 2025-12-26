provider "azuredevops" {}

resource "azuredevops_git_repository" "example" {
  project_id = var.project_id
  name       = var.repo_name

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_serviceendpoint_generic" "example" {
  project_id            = var.project_id
  service_endpoint_name = var.service_endpoint_name
  server_url            = var.service_endpoint_url
  username              = var.service_endpoint_username
  password              = var.service_endpoint_password
  description           = "Managed by Terraform"
}

module "azuredevops_pipelines" {
  source = "../../"

  project_id = var.project_id

  build_folders = [
    {
      key         = "pipelines"
      path        = "\\Pipelines"
      description = "Pipeline folder"
    }
  ]

  build_definitions = {
    app = {
      name = var.pipeline_app_name
      path = "\\Pipelines"
      repository = {
        repo_type = "TfsGit"
        repo_id   = azuredevops_git_repository.example.id
        yml_path  = var.yaml_path
      }
      schedules = [
        {
          branch_filter = {
            include = ["main"]
            exclude = ["experimental"]
          }
          days_to_build              = ["Mon", "Wed", "Fri"]
          schedule_only_with_changes = true
          start_hours                = 8
          start_minutes              = 30
          time_zone                  = "(UTC) Coordinated Universal Time"
        }
      ]
      variables = [
        {
          name  = "ENV"
          value = "dev"
        }
      ]
    }
    release = {
      name = var.pipeline_release_name
      repository = {
        repo_type = "TfsGit"
        repo_id   = azuredevops_git_repository.example.id
        yml_path  = "azure-pipelines-release.yml"
      }
      ci_trigger = {
        use_yaml = true
      }
    }
  }

  pipeline_authorizations = [
    {
      key          = "app-endpoint"
      resource_id  = azuredevops_serviceendpoint_generic.example.id
      type         = "endpoint"
      pipeline_key = "app"
    },
    {
      key          = "release-endpoint"
      resource_id  = azuredevops_serviceendpoint_generic.example.id
      type         = "endpoint"
      pipeline_key = "release"
    }
  ]
}
