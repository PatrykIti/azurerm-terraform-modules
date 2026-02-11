resource "azurerm_redis_cache" "redis_cache" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  capacity                           = var.capacity
  family                             = var.family
  sku_name                           = var.sku_name
  minimum_tls_version                = var.minimum_tls_version
  non_ssl_port_enabled               = var.non_ssl_port_enabled
  public_network_access_enabled      = var.public_network_access_enabled
  redis_version                      = var.redis_version
  access_keys_authentication_enabled = var.access_keys_authentication_enabled

  subnet_id                 = var.subnet_id
  private_static_ip_address = var.private_static_ip_address

  shard_count          = var.shard_count
  replicas_per_master  = var.replicas_per_master
  replicas_per_primary = var.replicas_per_primary

  tenant_settings = var.tenant_settings
  zones           = var.zones

  dynamic "redis_configuration" {
    for_each = var.redis_configuration == null ? [] : [var.redis_configuration]
    content {
      active_directory_authentication_enabled = try(redis_configuration.value.active_directory_authentication_enabled, null)
      aof_backup_enabled                      = try(redis_configuration.value.aof_backup_enabled, null)
      aof_storage_connection_string_0         = try(redis_configuration.value.aof_storage_connection_string_0, null)
      aof_storage_connection_string_1         = try(redis_configuration.value.aof_storage_connection_string_1, null)
      authentication_enabled                  = try(redis_configuration.value.authentication_enabled, null)
      data_persistence_authentication_method  = try(redis_configuration.value.data_persistence_authentication_method, null)
      maxfragmentationmemory_reserved         = try(redis_configuration.value.maxfragmentationmemory_reserved, null)
      maxmemory_delta                         = try(redis_configuration.value.maxmemory_delta, null)
      maxmemory_policy                        = try(redis_configuration.value.maxmemory_policy, null)
      maxmemory_reserved                      = try(redis_configuration.value.maxmemory_reserved, null)
      notify_keyspace_events                  = try(redis_configuration.value.notify_keyspace_events, null)
      rdb_backup_enabled                      = try(redis_configuration.value.rdb_backup_enabled, null)
      rdb_backup_frequency                    = try(redis_configuration.value.rdb_backup_frequency, null)
      rdb_backup_max_snapshot_count           = try(redis_configuration.value.rdb_backup_max_snapshot_count, null)
      rdb_storage_connection_string           = try(redis_configuration.value.rdb_storage_connection_string, null)
      storage_account_subscription_id         = try(redis_configuration.value.storage_account_subscription_id, null)
    }
  }

  dynamic "patch_schedule" {
    for_each = var.patch_schedule
    content {
      day_of_week        = patch_schedule.value.day_of_week
      start_hour_utc     = try(patch_schedule.value.start_hour_utc, null)
      maintenance_window = try(patch_schedule.value.maintenance_window, null)
    }
  }

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

resource "azurerm_redis_firewall_rule" "redis_firewall_rule" {
  for_each = var.public_network_access_enabled ? {
    for rule in var.firewall_rules : rule.name => rule
  } : {}

  name                = each.value.name
  redis_cache_name    = azurerm_redis_cache.redis_cache.name
  resource_group_name = azurerm_redis_cache.redis_cache.resource_group_name
  start_ip            = each.value.start_ip_address
  end_ip              = each.value.end_ip_address
}

resource "azurerm_redis_linked_server" "redis_linked_server" {
  for_each = var.sku_name == "Premium" ? {
    for ls in var.linked_servers : ls.name => ls
  } : {}

  resource_group_name         = azurerm_redis_cache.redis_cache.resource_group_name
  target_redis_cache_name     = azurerm_redis_cache.redis_cache.name
  linked_redis_cache_id       = each.value.linked_redis_cache_id
  linked_redis_cache_location = each.value.linked_redis_cache_location
  server_role                 = each.value.server_role
}
