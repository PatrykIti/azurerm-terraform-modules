locals {
  federated_identity_credentials = {
    for credential in var.federated_identity_credentials : credential.name => credential
  }
}

resource "azurerm_user_assigned_identity" "main" {
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

resource "azurerm_federated_identity_credential" "main" {
  for_each = local.federated_identity_credentials

  name                = each.value.name
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.main.id
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

  lifecycle {
    precondition {
      condition     = can(regex("^https://", each.value.issuer)) && length(trimspace(each.value.issuer)) > 8
      error_message = "Federated identity credential issuer must be a valid HTTPS URL."
    }
    precondition {
      condition     = length(trimspace(each.value.subject)) > 0
      error_message = "Federated identity credential subject must not be empty."
    }
    precondition {
      condition     = length(each.value.audience) > 0
      error_message = "Federated identity credential audience must contain at least one value."
    }
    precondition {
      condition     = alltrue([for aud in each.value.audience : length(trimspace(aud)) > 0])
      error_message = "Federated identity credential audience values must not be empty."
    }
  }
}
