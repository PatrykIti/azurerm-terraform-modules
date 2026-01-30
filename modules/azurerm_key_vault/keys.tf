resource "azurerm_key_vault_key" "keys" {
  for_each = local.keys_by_name

  name         = each.value.name
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = each.value.key_type
  key_opts     = each.value.key_opts

  key_size        = each.value.key_size
  curve           = each.value.curve
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date

  dynamic "rotation_policy" {
    for_each = each.value.rotation_policy == null ? [] : [each.value.rotation_policy]
    content {
      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry

      dynamic "automatic" {
        for_each = rotation_policy.value.automatic == null ? [] : [rotation_policy.value.automatic]
        content {
          time_after_creation = automatic.value.time_after_creation
          time_before_expiry  = automatic.value.time_before_expiry
        }
      }
    }
  }

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
      condition     = !contains(["RSA", "RSA-HSM"], each.value.key_type) || (each.value.key_size != null && contains([2048, 3072, 4096], each.value.key_size))
      error_message = "RSA and RSA-HSM keys require key_size of 2048, 3072, or 4096."
    }

    precondition {
      condition     = !contains(["EC", "EC-HSM"], each.value.key_type) || (each.value.curve != null && contains(["P-256", "P-384", "P-521", "P-256K"], each.value.curve))
      error_message = "EC and EC-HSM keys require curve set to P-256, P-384, P-521, or P-256K."
    }
  }
}
