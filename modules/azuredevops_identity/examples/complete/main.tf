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
    platform = {
      display_name = "${var.group_name_prefix}-platform-${random_string.suffix.result}"
      description  = "Platform engineering group"
    }
    developers = {
      display_name = "${var.group_name_prefix}-developers-${random_string.suffix.result}"
      description  = "Development contributors"
    }
  }

  group_memberships = [
    {
      key               = "platform-membership"
      group_key         = "platform"
      member_group_keys = ["developers"]
      mode              = "add"
    }
  ]

  user_entitlements = var.user_principal_name != "" ? [
    {
      key                  = "user-entitlement"
      principal_name       = var.user_principal_name
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ] : []

  group_entitlements = var.aad_group_display_name != "" ? [
    {
      key                  = "group-entitlement"
      display_name         = var.aad_group_display_name
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ] : []

  service_principal_entitlements = var.service_principal_origin_id != "" ? [
    {
      key                  = "service-principal-entitlement"
      origin_id            = var.service_principal_origin_id
      origin               = "aad"
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ] : []

  securityrole_assignments = var.security_role_assignment_resource_id != "" ? [
    {
      key                = "platform-reader"
      scope              = var.security_role_assignment_scope
      resource_id        = var.security_role_assignment_resource_id
      role_name          = var.security_role_assignment_role_name
      identity_group_key = "platform"
    }
  ] : []
}
