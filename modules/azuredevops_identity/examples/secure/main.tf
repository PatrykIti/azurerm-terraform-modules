provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_identity" {
  source = "../../"

  groups = {
    security = {
      display_name = "${var.group_name_prefix}-security-${random_string.suffix.result}"
      description  = "Security reviewers"
    }
    operators = {
      display_name = "${var.group_name_prefix}-operators-${random_string.suffix.result}"
      description  = "Operations access"
    }
  }

  group_memberships = [
    {
      key               = "security-membership"
      group_key         = "security"
      member_group_keys = ["operators"]
      mode              = "overwrite"
    }
  ]

  user_entitlements = var.user_principal_name != "" ? [
    {
      key                  = "stakeholder-user"
      principal_name       = var.user_principal_name
      account_license_type = "stakeholder"
      licensing_source     = "account"
    }
  ] : []

  group_entitlements = var.aad_group_display_name != "" ? [
    {
      key                  = "stakeholder-group"
      display_name         = var.aad_group_display_name
      account_license_type = "stakeholder"
      licensing_source     = "account"
    }
  ] : []
}
