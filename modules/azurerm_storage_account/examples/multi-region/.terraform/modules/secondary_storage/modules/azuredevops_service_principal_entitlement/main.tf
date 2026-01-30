# Azure DevOps Service Principal Entitlement

resource "azuredevops_service_principal_entitlement" "service_principal_entitlement" {
  origin_id            = var.origin_id
  origin               = var.origin
  account_license_type = var.account_license_type
  licensing_source     = var.licensing_source
}
