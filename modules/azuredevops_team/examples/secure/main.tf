provider "azuredevops" {}

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

module "azuredevops_team" {
  source = "../../"

  project_id  = var.project_id
  name        = var.team_name
  description = "Security review team"

  team_administrators = [
    {
      key               = "security-admins"
      admin_descriptors = [data.azuredevops_group.project_collection_admins.descriptor]
      mode              = "overwrite"
    }
  ]
}
