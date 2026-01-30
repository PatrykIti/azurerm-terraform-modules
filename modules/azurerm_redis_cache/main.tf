locals {
  sku_is_premium  = var.sku_name == "Premium"
  sku_is_standard = var.sku_name == "Standard"
  sku_is_basic    = var.sku_name == "Basic"

  family_is_premium  = var.family == "P"
  family_is_standard = var.family == "C"

  capacity_for_premium  = var.capacity >= 1 && var.capacity <= 5
  capacity_for_standard = var.capacity >= 0 && var.capacity <= 6

  sku_family_capacity_valid = (
    local.sku_is_premium && local.family_is_premium && local.capacity_for_premium
    ) || (
    (local.sku_is_basic || local.sku_is_standard) && local.family_is_standard && local.capacity_for_standard
  )

  replicas_configured = var.replicas_per_master != null || var.replicas_per_primary != null
}

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

  lifecycle {
    precondition {
      condition     = local.sku_family_capacity_valid
      error_message = "sku_name/family/capacity must be Basic/Standard with family C and capacity 0-6, or Premium with family P and capacity 1-5."
    }

    precondition {
      condition     = var.subnet_id == null || local.sku_is_premium
      error_message = "subnet_id is only supported with Premium SKU."
    }

    precondition {
      condition     = var.subnet_id == null || (var.private_static_ip_address != null && var.private_static_ip_address != "")
      error_message = "private_static_ip_address is required when subnet_id is set."
    }

    precondition {
      condition     = var.subnet_id == null || var.public_network_access_enabled == false
      error_message = "public_network_access_enabled must be false when subnet_id is set."
    }

    precondition {
      condition     = var.private_static_ip_address == null || (var.subnet_id != null && var.subnet_id != "")
      error_message = "private_static_ip_address requires subnet_id."
    }

    precondition {
      condition     = var.shard_count == null || local.sku_is_premium
      error_message = "shard_count is only supported with Premium SKU."
    }

    precondition {
      condition     = !local.replicas_configured || local.sku_is_premium
      error_message = "replicas_per_master/replicas_per_primary are only supported with Premium SKU."
    }

    precondition {
      condition     = var.shard_count == null || !local.replicas_configured
      error_message = "replicas_per_master/replicas_per_primary cannot be used with shard_count."
    }

    precondition {
      condition     = !(var.replicas_per_master != null && var.replicas_per_primary != null)
      error_message = "replicas_per_master and replicas_per_primary are mutually exclusive; set only one."
    }

    precondition {
      condition     = length(var.patch_schedule) == 0 || local.sku_is_premium
      error_message = "patch_schedule is only supported with Premium SKU."
    }

    precondition {
      condition     = length(var.linked_servers) == 0 || local.sku_is_premium
      error_message = "linked_servers are only supported with Premium SKU."
    }

    precondition {
      condition     = length(var.firewall_rules) == 0 || var.public_network_access_enabled
      error_message = "firewall_rules require public_network_access_enabled = true."
    }

    precondition {
      condition = var.access_keys_authentication_enabled || (
        var.redis_configuration != null &&
        try(var.redis_configuration.active_directory_authentication_enabled, false)
      )
      error_message = "When access_keys_authentication_enabled is false, redis_configuration.active_directory_authentication_enabled must be true."
    }
  }
}
