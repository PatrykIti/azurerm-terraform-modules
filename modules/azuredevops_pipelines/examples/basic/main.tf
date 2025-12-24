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

module "azuredevops_pipelines" {
  source = "../../"

  project_id = var.project_id

  build_definitions = {
    basic = {
      name = "${var.pipeline_name_prefix}-${random_string.suffix.result}"
      repository = {
        repo_type = "TfsGit"
        repo_id   = azuredevops_git_repository.example.id
        yml_path  = var.yaml_path
      }
      ci_trigger = {
        use_yaml = true
      }
    }
  }
}
