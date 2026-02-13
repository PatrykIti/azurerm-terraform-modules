# Azure DevOps Group Entitlement

locals {
  group_entitlement_key = coalesce(
    var.group_entitlement.key,
    var.group_entitlement.display_name,
    var.group_entitlement.origin_id
  )
}

resource "azuredevops_group_entitlement" "group_entitlement" {
  display_name         = var.group_entitlement.display_name
  origin               = var.group_entitlement.origin
  origin_id            = var.group_entitlement.origin_id
  account_license_type = var.group_entitlement.account_license_type
  licensing_source     = var.group_entitlement.licensing_source

  lifecycle {
    precondition {
      condition     = local.group_entitlement_key != null && trimspace(local.group_entitlement_key) != ""
      error_message = "group_entitlement must include a non-empty key, display_name, or origin_id."
    }
  }
}
