provider "azuredevops" {}

module "azuredevops_team" {
  source = "../../"

  project_id = var.project_id

  teams = {
    core = {
      name        = var.team_name
      description = "Core delivery team"
    }
  }

  team_members = length(var.member_descriptors) > 0 ? [
    {
      key                = "core-members"
      team_key           = "core"
      member_descriptors = var.member_descriptors
    }
  ] : []
}
