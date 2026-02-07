resource "azurerm_key_vault_access_policy" "access_policies" {
  for_each = {
    for policy in var.access_policies : policy.name => policy
  }

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
}
