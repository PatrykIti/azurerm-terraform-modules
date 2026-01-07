# Azure DevOps Service Principal Entitlement

locals {
  service_principal_entitlements = {
    for entitlement in var.service_principal_entitlements :
    coalesce(entitlement.key, entitlement.origin_id) => entitlement
  }
}

resource "azuredevops_service_principal_entitlement" "service_principal_entitlement" {
  for_each = local.service_principal_entitlements

  origin_id            = each.value.origin_id
  origin               = each.value.origin
  account_license_type = each.value.account_license_type
  licensing_source     = each.value.licensing_source
}
