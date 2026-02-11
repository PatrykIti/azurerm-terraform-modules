resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "timeouts" {
    for_each = (
      var.timeouts.create != null ||
      var.timeouts.update != null ||
      var.timeouts.delete != null ||
      var.timeouts.read != null
    ) ? [var.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}

resource "azurerm_federated_identity_credential" "federated_identity_credential" {
  for_each = {
    for credential in var.federated_identity_credentials : credential.name => credential
  }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.user_assigned_identity.id
  issuer              = each.value.issuer
  subject             = each.value.subject
  audience            = each.value.audience

  dynamic "timeouts" {
    for_each = (
      var.federated_identity_credential_timeouts.create != null ||
      var.federated_identity_credential_timeouts.update != null ||
      var.federated_identity_credential_timeouts.delete != null ||
      var.federated_identity_credential_timeouts.read != null
    ) ? [var.federated_identity_credential_timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}
