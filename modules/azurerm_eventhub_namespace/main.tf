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
}

resource "azurerm_eventhub_namespace_authorization_rule" "authorization_rules" {
  for_each = {
    for rule in var.namespace_authorization_rules : rule.name => rule
  }

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name

  listen = try(each.value.listen, false)
  send   = try(each.value.send, false)
  manage = try(each.value.manage, false)
}

resource "azurerm_eventhub_namespace_schema_group" "schema_group" {
  for_each = {
    for group in var.schema_groups : group.name => group
  }

  name                 = each.value.name
  namespace_id         = azurerm_eventhub_namespace.namespace.id
  schema_compatibility = each.value.schema_compatibility
  schema_type          = each.value.schema_type

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
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
}
