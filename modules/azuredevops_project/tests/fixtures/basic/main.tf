provider "azuredevops" {}

module "azuredevops_project" {
  source = "../../../"

  project = {
    name               = var.project_name
    description        = "Test basic Azure DevOps project"
    visibility         = "private"
    version_control    = "Git"
    work_item_template = "Agile"
  }

  project_tags = ["test", "basic"]
}
