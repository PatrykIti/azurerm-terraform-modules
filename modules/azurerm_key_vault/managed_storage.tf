resource "azurerm_key_vault_managed_storage_account" "managed_storage_accounts" {
  for_each = local.managed_storage_accounts_by_name

  name                = each.value.name
  key_vault_id        = azurerm_key_vault.key_vault.id
  storage_account_id  = each.value.storage_account_id
  storage_account_key = sensitive(each.value.storage_account_key)

  regenerate_key_automatically = each.value.regenerate_key_automatically
  regeneration_period          = each.value.regeneration_period

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
      condition     = !each.value.regenerate_key_automatically || (each.value.regeneration_period != null && length(trimspace(each.value.regeneration_period)) > 0)
      error_message = "regeneration_period is required when regenerate_key_automatically is true."
    }
  }
}

resource "azurerm_key_vault_managed_storage_account_sas_token_definition" "sas_definitions" {
  for_each = local.managed_storage_sas_definitions_by_name

  name                       = each.value.name
  managed_storage_account_id = each.value.managed_storage_account_id != null ? each.value.managed_storage_account_id : azurerm_key_vault_managed_storage_account.managed_storage_accounts[each.value.managed_storage_account_name].id
  sas_template_uri           = each.value.sas_template_uri
  sas_type                   = each.value.sas_type
  validity_period            = each.value.validity_period

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

  depends_on = [
    azurerm_key_vault_access_policy.access_policies,
    azurerm_key_vault_managed_storage_account.managed_storage_accounts
  ]

  lifecycle {
    precondition {
      condition     = (each.value.managed_storage_account_name != null ? 1 : 0) + (each.value.managed_storage_account_id != null ? 1 : 0) == 1
      error_message = "managed_storage_account_name or managed_storage_account_id must be set, but not both."
    }
  }
}
