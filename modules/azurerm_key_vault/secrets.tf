resource "azurerm_key_vault_secret" "secrets" {
  for_each = local.secrets_by_name

  name         = each.value.name
  key_vault_id = azurerm_key_vault.key_vault.id

  value            = each.value.value != null ? sensitive(each.value.value) : null
  value_wo         = each.value.value_wo != null ? sensitive(each.value.value_wo) : null
  value_wo_version = each.value.value_wo_version
  content_type     = each.value.content_type
  not_before_date  = each.value.not_before_date
  expiration_date  = each.value.expiration_date

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))

  depends_on = [azurerm_key_vault_access_policy.access_policies]

  lifecycle {
    precondition {
      condition     = ((each.value.value != null ? 1 : 0) + (each.value.value_wo != null ? 1 : 0)) == 1
      error_message = "Each secret must set exactly one of value or value_wo."
    }

    precondition {
      condition     = each.value.value_wo == null || each.value.value_wo_version != null
      error_message = "value_wo requires value_wo_version."
    }
  }
}
