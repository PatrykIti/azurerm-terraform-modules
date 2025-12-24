provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azuredevops_git_repository" "example" {
  project_id = var.project_id
  name       = "${var.repo_name_prefix}-${random_string.suffix.result}"

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_serviceendpoint_generic" "example" {
  project_id            = var.project_id
  service_endpoint_name = "${var.service_endpoint_name_prefix}-${random_string.suffix.result}"
  server_url            = var.service_endpoint_url
  username              = var.service_endpoint_username
  password              = var.service_endpoint_password
  description           = "Managed by Terraform"
}

module "azuredevops_pipelines" {
  source = "../.."

  project_id = var.project_id

  build_folders = [
    {
      path        = "\\Pipelines"
      description = "Pipeline folder"
    }
  ]

  build_definitions = {
    app = {
      name = "${var.pipeline_name_prefix}-app-${random_string.suffix.result}"
      path = "\\Pipelines"
      repository = {
        repo_type = "TfsGit"
        repo_id   = azuredevops_git_repository.example.id
        yml_path  = var.yaml_path
      }
      ci_trigger = {
        use_yaml = true
      }
    }
    release = {
      name = "${var.pipeline_name_prefix}-release-${random_string.suffix.result}"
      repository = {
        repo_type = "TfsGit"
        repo_id   = azuredevops_git_repository.example.id
        yml_path  = "azure-pipelines-release.yml"
      }
    }
  }

  pipeline_authorizations = [
    {
      resource_id  = azuredevops_serviceendpoint_generic.example.id
      type         = "endpoint"
      pipeline_key = "app"
    },
    {
      resource_id  = azuredevops_serviceendpoint_generic.example.id
      type         = "endpoint"
      pipeline_key = "release"
    }
  ]
}
