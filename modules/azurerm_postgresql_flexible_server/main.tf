resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = var.sku_name
  version  = var.postgresql_version

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  storage_mb   = var.storage == null ? null : var.storage.storage_mb
  storage_tier = var.storage == null ? null : var.storage.storage_tier

  backup_retention_days        = var.backup == null ? null : var.backup.retention_days
  geo_redundant_backup_enabled = var.backup == null ? null : var.backup.geo_redundant_backup_enabled

  public_network_access_enabled = (
    var.network != null && var.network.public_network_access_enabled != null
    ? var.network.public_network_access_enabled
    : !(
      (var.network != null && var.network.delegated_subnet_id != null) ||
      (var.network != null && var.network.private_dns_zone_id != null)
    )
  )
  delegated_subnet_id = var.network == null ? null : var.network.delegated_subnet_id
  private_dns_zone_id = var.network == null ? null : var.network.private_dns_zone_id

  zone = var.zone

  create_mode                       = var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default"
  source_server_id                  = var.create_mode == null ? null : var.create_mode.source_server_id
  point_in_time_restore_time_in_utc = var.create_mode == null ? null : var.create_mode.point_in_time_restore_time_in_utc

  dynamic "authentication" {
    for_each = var.authentication == null ? [] : [var.authentication]
    content {
      active_directory_auth_enabled = authentication.value.active_directory_auth_enabled
      password_auth_enabled         = authentication.value.password_auth_enabled
      tenant_id                     = authentication.value.tenant_id
    }
  }

  dynamic "high_availability" {
    for_each = var.high_availability != null ? [var.high_availability] : []
    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = high_availability.value.standby_availability_zone
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], identity.value.type) ? identity.value.identity_ids : null
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []
    content {
      key_vault_key_id                     = customer_managed_key.value.key_vault_key_id
      primary_user_assigned_identity_id    = customer_managed_key.value.primary_user_assigned_identity_id
      geo_backup_key_vault_key_id          = customer_managed_key.value.geo_backup_key_vault_key_id
      geo_backup_user_assigned_identity_id = customer_managed_key.value.geo_backup_user_assigned_identity_id
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.authentication == null ? true : (var.authentication.active_directory_auth_enabled || var.authentication.password_auth_enabled)
      error_message = "At least one authentication method must be enabled."
    }

    precondition {
      condition = !(var.authentication != null && var.authentication.active_directory_auth_enabled) || (
        var.active_directory_administrator != null && (
          (var.authentication != null && var.authentication.tenant_id != null && var.authentication.tenant_id != "") ||
          (var.active_directory_administrator.tenant_id != null && var.active_directory_administrator.tenant_id != "")
        )
      )
      error_message = "authentication.tenant_id or active_directory_administrator.tenant_id and active_directory_administrator are required when active_directory_auth_enabled is true."
    }

    precondition {
      condition     = var.active_directory_administrator == null || (var.authentication != null && var.authentication.active_directory_auth_enabled)
      error_message = "active_directory_administrator requires authentication.active_directory_auth_enabled = true."
    }

    precondition {
      condition = (var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default") != "Default" || (
        !(var.authentication == null ? true : var.authentication.password_auth_enabled) || (
          var.administrator_login != null && var.administrator_login != "" &&
          var.administrator_password != null && var.administrator_password != ""
        )
      )
      error_message = "administrator_login and administrator_password are required when create_mode is Default and password authentication is enabled."
    }

    precondition {
      condition = (
        var.network != null && var.network.public_network_access_enabled != null
        ? var.network.public_network_access_enabled
        : !(
          (var.network != null && var.network.delegated_subnet_id != null) ||
          (var.network != null && var.network.private_dns_zone_id != null)
        )
        ) || (
        var.network != null &&
        var.network.delegated_subnet_id != null &&
        var.network.private_dns_zone_id != null
      )
      error_message = "network.delegated_subnet_id and network.private_dns_zone_id are required when public_network_access_enabled is false."
    }

    precondition {
      condition = !(
        var.network != null &&
        (var.network.delegated_subnet_id != null || var.network.private_dns_zone_id != null)
        ) || !(
        var.network != null && var.network.public_network_access_enabled != null
        ? var.network.public_network_access_enabled
        : !(
          (var.network != null && var.network.delegated_subnet_id != null) ||
          (var.network != null && var.network.private_dns_zone_id != null)
        )
      )
      error_message = "network.delegated_subnet_id/private_dns_zone_id require public_network_access_enabled = false."
    }

    precondition {
      condition = length(var.firewall_rules) == 0 || (
        var.network != null && var.network.public_network_access_enabled != null
        ? var.network.public_network_access_enabled
        : !(
          (var.network != null && var.network.delegated_subnet_id != null) ||
          (var.network != null && var.network.private_dns_zone_id != null)
        )
      )
      error_message = "firewall_rules require public_network_access_enabled = true."
    }

    precondition {
      condition = (var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default") != "Default" || (
        (var.create_mode == null || var.create_mode.source_server_id == null) &&
        (var.create_mode == null || var.create_mode.point_in_time_restore_time_in_utc == null)
      )
      error_message = "source_server_id and point_in_time_restore_time_in_utc must be null when create_mode is Default."
    }

    precondition {
      condition = !contains([
        "Replica",
        "PointInTimeRestore",
        "GeoRestore",
        "ReviveDropped"
        ], (var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default")) || (
        var.create_mode != null && var.create_mode.source_server_id != null
      )
      error_message = "source_server_id is required when create_mode is Replica, PointInTimeRestore, GeoRestore, or ReviveDropped."
    }

    precondition {
      condition = (var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default") != "PointInTimeRestore" || (
        var.create_mode != null && var.create_mode.point_in_time_restore_time_in_utc != null
      )
      error_message = "point_in_time_restore_time_in_utc is required when create_mode is PointInTimeRestore."
    }

    precondition {
      condition = (
        (var.create_mode == null || var.create_mode.point_in_time_restore_time_in_utc == null) ||
        (var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default") == "PointInTimeRestore"
      )
      error_message = "point_in_time_restore_time_in_utc is only valid when create_mode is PointInTimeRestore."
    }

    precondition {
      condition = var.customer_managed_key == null || (
        var.identity != null && contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
      )
      error_message = "customer_managed_key requires identity.type to include UserAssigned."
    }

    precondition {
      condition = var.customer_managed_key == null || (
        var.identity != null &&
        var.identity.identity_ids != null &&
        contains(var.identity.identity_ids, var.customer_managed_key.primary_user_assigned_identity_id)
      )
      error_message = "customer_managed_key.primary_user_assigned_identity_id must be included in identity.identity_ids."
    }
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "configurations" {
  for_each = { for cfg in var.configurations : cfg.name => cfg }

  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  value     = each.value.value
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "firewall_rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name             = each.value.name
  server_id        = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "active_directory_administrator" {
  count = var.active_directory_administrator != null ? 1 : 0

  server_name         = azurerm_postgresql_flexible_server.postgresql_flexible_server.name
  resource_group_name = var.resource_group_name
  tenant_id = var.active_directory_administrator == null ? null : (
    var.active_directory_administrator.tenant_id != null ? var.active_directory_administrator.tenant_id : (
      var.authentication == null ? null : var.authentication.tenant_id
    )
  )
  object_id      = var.active_directory_administrator == null ? null : var.active_directory_administrator.object_id
  principal_name = var.active_directory_administrator == null ? null : var.active_directory_administrator.principal_name
  principal_type = var.active_directory_administrator == null ? null : var.active_directory_administrator.principal_type
}

resource "azurerm_postgresql_flexible_server_virtual_endpoint" "virtual_endpoints" {
  for_each = { for ve in var.virtual_endpoints : ve.name => ve }

  name              = each.value.name
  source_server_id  = coalesce(each.value.source_server_id, azurerm_postgresql_flexible_server.postgresql_flexible_server.id)
  replica_server_id = coalesce(each.value.replica_server_id, azurerm_postgresql_flexible_server.postgresql_flexible_server.id)
  type              = each.value.type
}

resource "azurerm_postgresql_flexible_server_backup" "backups" {
  for_each = { for backup in var.backups : backup.name => backup }

  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
}
