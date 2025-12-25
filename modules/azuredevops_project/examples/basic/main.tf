provider "azuredevops" {}

module "azuredevops_project" {
  source = "../../"

  name               = var.project_name
  description        = "Basic Azure DevOps project managed by Terraform"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  project_tags = ["basic", "terraform"]
}
