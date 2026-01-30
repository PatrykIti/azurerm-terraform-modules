resource "azurerm_key_vault_access_policy" "access_policies" {
  for_each = local.access_policies_by_name

  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = coalesce(each.value.tenant_id, var.tenant_id)
  object_id    = each.value.object_id

  application_id          = each.value.application_id
  certificate_permissions = each.value.certificate_permissions
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  storage_permissions     = each.value.storage_permissions

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = !var.rbac_authorization_enabled
      error_message = "access_policies cannot be used when rbac_authorization_enabled is true."
    }
  }
}
