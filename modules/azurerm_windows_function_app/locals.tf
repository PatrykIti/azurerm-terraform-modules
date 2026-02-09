locals {
  slots_by_name = { for slot in var.slots : slot.name => slot }

  storage_key_vault_secret_id_set = var.storage_configuration.key_vault_secret_id != null && var.storage_configuration.key_vault_secret_id != ""

  slot_storage = {
    for slot in var.slots : slot.name => {
      storage_key_vault_secret_id = coalesce(slot.storage_key_vault_secret_id, var.storage_configuration.key_vault_secret_id)
      storage_key_vault_secret_id_set = (
        coalesce(slot.storage_key_vault_secret_id, var.storage_configuration.key_vault_secret_id) != null &&
        coalesce(slot.storage_key_vault_secret_id, var.storage_configuration.key_vault_secret_id) != ""
      )
      storage_uses_managed_identity = coalesce(slot.storage_uses_managed_identity, var.storage_configuration.uses_managed_identity)
      storage_account_name = (
        (
          coalesce(slot.storage_key_vault_secret_id, var.storage_configuration.key_vault_secret_id) != null &&
          coalesce(slot.storage_key_vault_secret_id, var.storage_configuration.key_vault_secret_id) != ""
        ) ? null : coalesce(slot.storage_account_name, var.storage_configuration.account_name)
      )
      storage_account_access_key = (
        (
          coalesce(slot.storage_key_vault_secret_id, var.storage_configuration.key_vault_secret_id) != null &&
          coalesce(slot.storage_key_vault_secret_id, var.storage_configuration.key_vault_secret_id) != ""
          ) ? null : (
          coalesce(slot.storage_uses_managed_identity, var.storage_configuration.uses_managed_identity) ? null :
          coalesce(slot.storage_account_access_key, var.storage_configuration.account_access_key)
        )
      )
    }
  }
}
