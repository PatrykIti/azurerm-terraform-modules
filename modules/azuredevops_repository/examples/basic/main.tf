provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_repository" {
  source = "../../"

  project_id = var.project_id

  repositories = {
    main = {
      name = "${var.repo_name_prefix}-${random_string.suffix.result}"
      initialization = {
        init_type = "Clean"
      }
    }
  }

  files = [
    {
      repository_key  = "main"
      file            = "README.md"
      content         = "# Repository\n\nManaged by Terraform."
      commit_message  = "Add README"
      overwrite_on_create = true
    }
  ]
}
