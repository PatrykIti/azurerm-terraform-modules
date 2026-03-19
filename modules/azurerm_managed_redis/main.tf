locals {
  managed_redis_user_assigned_identity_types = [
    "UserAssigned",
    "SystemAssigned, UserAssigned",
  ]
}

resource "azurerm_managed_redis" "managed_redis" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name                  = var.managed_redis.sku_name
  high_availability_enabled = var.managed_redis.high_availability_enabled
  public_network_access     = var.managed_redis.public_network_access

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = contains(local.managed_redis_user_assigned_identity_types, identity.value.type) ? identity.value.identity_ids : null
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []
    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  dynamic "default_database" {
    for_each = var.default_database != null ? [var.default_database] : []
    content {
      access_keys_authentication_enabled            = try(default_database.value.access_keys_authentication_enabled, null)
      client_protocol                               = try(default_database.value.client_protocol, null)
      clustering_policy                             = try(default_database.value.clustering_policy, null)
      eviction_policy                               = try(default_database.value.eviction_policy, null)
      geo_replication_group_name                    = try(default_database.value.geo_replication_group_name, null)
      persistence_append_only_file_backup_frequency = try(default_database.value.persistence_append_only_file_backup_frequency, null)
      persistence_redis_database_backup_frequency   = try(default_database.value.persistence_redis_database_backup_frequency, null)

      dynamic "module" {
        for_each = try(default_database.value.modules, [])
        iterator = redis_module
        content {
          name = redis_module.value.name
          args = try(redis_module.value.args, null)
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = var.managed_redis.timeouts != null ? [var.managed_redis.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  lifecycle {
    precondition {
      condition = var.customer_managed_key == null || (
        var.identity != null &&
        contains(local.managed_redis_user_assigned_identity_types, var.identity.type)
      )
      error_message = "customer_managed_key requires identity.type to include UserAssigned."
    }

    precondition {
      condition = var.customer_managed_key == null || (
        var.identity != null &&
        var.identity.identity_ids != null &&
        contains(var.identity.identity_ids, var.customer_managed_key.user_assigned_identity_id)
      )
      error_message = "customer_managed_key.user_assigned_identity_id must be included in identity.identity_ids."
    }

    precondition {
      condition = var.geo_replication == null || (
        var.default_database != null &&
        try(var.default_database.geo_replication_group_name, null) != null
      )
      error_message = "geo_replication requires default_database.geo_replication_group_name to be set."
    }

    precondition {
      condition = var.default_database == null || !(
        try(var.default_database.persistence_append_only_file_backup_frequency, null) != null &&
        try(var.default_database.persistence_redis_database_backup_frequency, null) != null
      )
      error_message = "Only one persistence mode can be enabled at a time."
    }
  }

  tags = var.tags
}

resource "azurerm_managed_redis_geo_replication" "geo_replication" {
  count = var.geo_replication != null ? 1 : 0

  managed_redis_id         = azurerm_managed_redis.managed_redis.id
  linked_managed_redis_ids = var.geo_replication == null ? [] : var.geo_replication.linked_managed_redis_ids

  dynamic "timeouts" {
    for_each = var.geo_replication != null && var.geo_replication.timeouts != null ? [var.geo_replication.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
