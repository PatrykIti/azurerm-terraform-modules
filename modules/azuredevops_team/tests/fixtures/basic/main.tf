provider "azuredevops" {}

module "azuredevops_team" {
  source = "../../"

  project_id = var.project_id

  teams = {
    core = {
      name        = "${var.team_name_prefix}-core"
      description = "Test core team"
    }
  }
}
