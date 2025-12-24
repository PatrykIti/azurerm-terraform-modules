# Team administrator fixture (optional inputs)
provider "azuredevops" {}

module "azuredevops_team" {
  source = "../../../"

  project_id = var.project_id

  teams = {
    audit = {
      name        = var.team_name
      description = "Audit team fixture"
    }
  }

  team_administrators = var.team_administrators
}
