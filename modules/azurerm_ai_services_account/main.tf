locals {
  identity_is_user_assigned = var.identity != null && strcontains(lower(var.identity.type), "userassigned")
  identity_ids_present      = var.identity != null && var.identity.identity_ids != null && length(var.identity.identity_ids) > 0
  cmk_enabled               = var.customer_managed_key != null
  network_acls_enabled      = var.network_acls != null
}

resource "azurerm_ai_services" "ai_services_account" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name

  custom_subdomain_name              = var.custom_subdomain_name
  fqdns                              = var.fqdns
  public_network_access              = var.public_network_access
  local_authentication_enabled       = var.local_authentication_enabled
  outbound_network_access_restricted = var.outbound_network_access_restricted

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : [var.customer_managed_key]
    content {
      key_vault_key_id   = try(customer_managed_key.value.key_vault_key_id, null)
      managed_hsm_key_id = try(customer_managed_key.value.managed_hsm_key_id, null)
      identity_client_id = try(customer_managed_key.value.identity_client_id, null)
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    content {
      default_action = network_acls.value.default_action
      bypass         = try(network_acls.value.bypass, null)
      ip_rules       = try(network_acls.value.ip_rules, null)

      dynamic "virtual_network_rules" {
        for_each = coalesce(network_acls.value.virtual_network_rules, [])
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = try(virtual_network_rules.value.ignore_missing_vnet_service_endpoint, null)
        }
      }
    }
  }

  dynamic "storage" {
    for_each = var.storage
    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = try(storage.value.identity_client_id, null)
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !local.network_acls_enabled || (var.custom_subdomain_name != null && var.custom_subdomain_name != "")
      error_message = "custom_subdomain_name is required when network_acls is specified."
    }

    precondition {
      condition     = !local.cmk_enabled || (var.identity != null && local.identity_is_user_assigned && local.identity_ids_present)
      error_message = "customer_managed_key requires a user-assigned identity with identity_ids."
    }
  }
}
