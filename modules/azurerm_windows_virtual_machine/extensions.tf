resource "azurerm_virtual_machine_extension" "virtual_machine_extension" {
  for_each = { for extension in var.extensions : extension.name => extension }

  name                 = each.value.name
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_virtual_machine.id
  publisher            = each.value.publisher
  type                 = each.value.type
  type_handler_version = each.value.type_handler_version

  auto_upgrade_minor_version  = each.value.auto_upgrade_minor_version
  automatic_upgrade_enabled   = each.value.automatic_upgrade_enabled
  failure_suppression_enabled = each.value.failure_suppression_enabled
  provision_after_extensions  = each.value.provision_after_extensions

  settings           = each.value.settings != null ? jsonencode(each.value.settings) : null
  protected_settings = each.value.protected_settings != null ? jsonencode(each.value.protected_settings) : null

  dynamic "protected_settings_from_key_vault" {
    for_each = each.value.protected_settings_from_key_vault != null ? [each.value.protected_settings_from_key_vault] : []
    content {
      secret_url      = protected_settings_from_key_vault.value.secret_url
      source_vault_id = protected_settings_from_key_vault.value.source_vault_id
    }
  }

  tags = try(each.value.tags, null)
}
