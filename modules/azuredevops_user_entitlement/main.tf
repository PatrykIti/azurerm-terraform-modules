# Azure DevOps User Entitlement

locals {
  user_entitlements = {
    for entitlement in var.user_entitlements :
    coalesce(entitlement.key, entitlement.principal_name, entitlement.origin_id) => entitlement
  }
}

resource "azuredevops_user_entitlement" "user_entitlement" {
  for_each = local.user_entitlements

  principal_name       = each.value.principal_name
  origin               = each.value.origin
  origin_id            = each.value.origin_id
  account_license_type = each.value.account_license_type
  licensing_source     = each.value.licensing_source
}
