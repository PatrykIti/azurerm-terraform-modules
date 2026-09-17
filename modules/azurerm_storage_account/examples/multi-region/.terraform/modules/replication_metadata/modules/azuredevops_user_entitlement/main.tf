# Azure DevOps User Entitlement

locals {
  user_entitlement_key = coalesce(
    var.user_entitlement.key,
    var.user_entitlement.principal_name,
    var.user_entitlement.origin_id
  )
}

resource "azuredevops_user_entitlement" "user_entitlement" {
  principal_name       = var.user_entitlement.principal_name
  origin               = var.user_entitlement.origin
  origin_id            = var.user_entitlement.origin_id
  account_license_type = var.user_entitlement.account_license_type
  licensing_source     = var.user_entitlement.licensing_source

  lifecycle {
    precondition {
      condition     = local.user_entitlement_key != null && trimspace(local.user_entitlement_key) != ""
      error_message = "user_entitlement must include a non-empty key, principal_name, or origin_id."
    }
  }
}
