locals {
  namespace_authorization_rules = {
    for rule in var.namespace_authorization_rules : rule.name => rule
  }

  network_rulesets = var.network_rule_set == null ? null : [
    {
      default_action                 = var.network_rule_set.default_action
      public_network_access_enabled  = try(var.network_rule_set.public_network_access_enabled, null)
      trusted_service_access_enabled = try(var.network_rule_set.trusted_service_access_enabled, null)
      virtual_network_rule = [
        for rule in try(var.network_rule_set.vnet_rules, []) : {
          subnet_id                                       = rule.subnet_id
          ignore_missing_virtual_network_service_endpoint = try(rule.ignore_missing_vnet_service_endpoint, null)
        }
      ]
      ip_rule = [
        for rule in try(var.network_rule_set.ip_rules, []) : {
          ip_mask = rule.ip_mask
          action  = try(rule.action, "Allow")
        }
      ]
    }
  ]

  identity_type                = try(var.identity.type, null)
  identity_ids                 = try(var.identity.identity_ids, [])
  identity_has_user_assigned   = local.identity_type != null && contains(["UserAssigned", "SystemAssigned, UserAssigned"], local.identity_type)
  identity_has_system_assigned = local.identity_type != null && contains(["SystemAssigned", "SystemAssigned, UserAssigned"], local.identity_type)

  cmk_user_assigned_identity_id = try(var.customer_managed_key.user_assigned_identity_id, null)
  cmk_requires_user_assigned    = var.customer_managed_key != null && local.cmk_user_assigned_identity_id != null
  cmk_requires_system_assigned  = var.customer_managed_key != null && local.cmk_user_assigned_identity_id == null
}

resource "azurerm_eventhub_namespace" "namespace" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku      = var.sku
  capacity = var.capacity

  auto_inflate_enabled     = var.auto_inflate_enabled
  maximum_throughput_units = var.maximum_throughput_units

  dedicated_cluster_id = var.dedicated_cluster_id

  public_network_access_enabled = var.public_network_access_enabled
  local_authentication_enabled  = var.local_authentication_enabled
  minimum_tls_version           = var.minimum_tls_version

  network_rulesets = local.network_rulesets

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
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
      condition     = !var.auto_inflate_enabled || var.maximum_throughput_units != null
      error_message = "maximum_throughput_units is required when auto_inflate_enabled is true."
    }

    precondition {
      condition     = var.network_rule_set == null || var.network_rule_set.public_network_access_enabled == null || var.network_rule_set.public_network_access_enabled == var.public_network_access_enabled
      error_message = "network_rule_set.public_network_access_enabled must match public_network_access_enabled when set."
    }
  }
}

resource "azurerm_eventhub_namespace_authorization_rule" "authorization_rules" {
  for_each = local.namespace_authorization_rules

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name

  listen = try(each.value.listen, false)
  send   = try(each.value.send, false)
  manage = try(each.value.manage, false)
}

resource "azurerm_eventhub_namespace_disaster_recovery_config" "disaster_recovery" {
  for_each = var.disaster_recovery_config == null ? {} : {
    (var.disaster_recovery_config.name) = var.disaster_recovery_config
  }

  name                 = each.value.name
  namespace_name       = azurerm_eventhub_namespace.namespace.name
  resource_group_name  = var.resource_group_name
  partner_namespace_id = each.value.partner_namespace_id
}

resource "azurerm_eventhub_namespace_customer_managed_key" "customer_managed_key" {
  count = var.customer_managed_key == null ? 0 : 1

  eventhub_namespace_id             = azurerm_eventhub_namespace.namespace.id
  key_vault_key_ids                 = var.customer_managed_key.key_vault_key_ids
  infrastructure_encryption_enabled = try(var.customer_managed_key.infrastructure_encryption_enabled, null)
  user_assigned_identity_id         = try(var.customer_managed_key.user_assigned_identity_id, null)

  lifecycle {
    precondition {
      condition = !local.cmk_requires_user_assigned || (
        local.identity_has_user_assigned &&
        length(local.identity_ids) > 0 &&
        contains(local.identity_ids, local.cmk_user_assigned_identity_id)
      )
      error_message = "customer_managed_key.user_assigned_identity_id requires the same identity to be assigned to the namespace (identity.type includes UserAssigned and identity.identity_ids contains the ID)."
    }

    precondition {
      condition     = !local.cmk_requires_system_assigned || local.identity_has_system_assigned
      error_message = "customer_managed_key requires a SystemAssigned identity when user_assigned_identity_id is not set."
    }
  }
}
