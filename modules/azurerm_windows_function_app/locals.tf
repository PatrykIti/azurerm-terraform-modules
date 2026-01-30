locals {
  slots_by_name = { for slot in var.slots : slot.name => slot }

  storage_key_vault_secret_id_set = var.storage_key_vault_secret_id != null && var.storage_key_vault_secret_id != ""

  storage_account_name_effective = local.storage_key_vault_secret_id_set ? null : var.storage_account_name
  storage_account_access_key_effective = local.storage_key_vault_secret_id_set ? null : (
    var.storage_uses_managed_identity ? null : var.storage_account_access_key
  )

  application_stack_count = var.site_config.application_stack == null ? 0 : (
    (var.site_config.application_stack.dotnet_version != null ? 1 : 0) +
    (var.site_config.application_stack.java_version != null ? 1 : 0) +
    (var.site_config.application_stack.node_version != null ? 1 : 0) +
    (var.site_config.application_stack.powershell_core_version != null ? 1 : 0) +
    (try(var.site_config.application_stack.use_custom_runtime, false) ? 1 : 0)
  )

  slot_application_stack_counts = {
    for slot in var.slots : slot.name => (
      slot.site_config != null && slot.site_config.application_stack != null ? (
        (slot.site_config.application_stack.dotnet_version != null ? 1 : 0) +
        (slot.site_config.application_stack.java_version != null ? 1 : 0) +
        (slot.site_config.application_stack.node_version != null ? 1 : 0) +
        (slot.site_config.application_stack.powershell_core_version != null ? 1 : 0) +
        (try(slot.site_config.application_stack.use_custom_runtime, false) ? 1 : 0)
      ) : 0
    )
  }

  slot_storage = {
    for slot in var.slots : slot.name => {
      storage_key_vault_secret_id = coalesce(slot.storage_key_vault_secret_id, var.storage_key_vault_secret_id)
      storage_key_vault_secret_id_set = (
        coalesce(slot.storage_key_vault_secret_id, var.storage_key_vault_secret_id) != null &&
        coalesce(slot.storage_key_vault_secret_id, var.storage_key_vault_secret_id) != ""
      )
      storage_uses_managed_identity = coalesce(slot.storage_uses_managed_identity, var.storage_uses_managed_identity)
      storage_account_name = (
        (
          coalesce(slot.storage_key_vault_secret_id, var.storage_key_vault_secret_id) != null &&
          coalesce(slot.storage_key_vault_secret_id, var.storage_key_vault_secret_id) != ""
        ) ? null : coalesce(slot.storage_account_name, var.storage_account_name)
      )
      storage_account_access_key = (
        (
          coalesce(slot.storage_key_vault_secret_id, var.storage_key_vault_secret_id) != null &&
          coalesce(slot.storage_key_vault_secret_id, var.storage_key_vault_secret_id) != ""
        ) ? null : (
          coalesce(slot.storage_uses_managed_identity, var.storage_uses_managed_identity) ? null :
          coalesce(slot.storage_account_access_key, var.storage_account_access_key)
        )
      )
    }
  }
}
