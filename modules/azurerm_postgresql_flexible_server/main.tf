locals {
  authentication = {
    active_directory_auth_enabled  = try(var.authentication.active_directory_auth_enabled, false)
    password_auth_enabled          = try(var.authentication.password_auth_enabled, true)
    tenant_id                      = try(var.authentication.tenant_id, null)
    administrator                  = try(var.authentication.administrator, null)
    active_directory_administrator = try(var.authentication.active_directory_administrator, null)
  }

  network = {
    public_network_access_enabled = try(var.network.public_network_access_enabled, null)
    delegated_subnet_id           = try(var.network.delegated_subnet_id, null)
    private_dns_zone_id           = try(var.network.private_dns_zone_id, null)
    firewall_rules                = try(var.network.firewall_rules, [])
  }

  identity = {
    type         = try(var.identity.type, null)
    identity_ids = try(var.identity.identity_ids, null)
  }

  encryption = try(var.server.encryption, null)

  features = {
    configurations  = try(var.features.configurations, [])
    virtual_endpoints = try(var.features.virtual_endpoints, [])
    backups         = try(var.features.backups, [])
  }

  monitoring = try(var.monitoring, [])

  public_network_access_enabled = (
    local.network.public_network_access_enabled != null
    ? local.network.public_network_access_enabled
    : !(
      local.network.delegated_subnet_id != null ||
      local.network.private_dns_zone_id != null
    )
  )
}

resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = var.server.sku_name
  version  = var.server.postgresql_version

  administrator_login    = try(local.authentication.administrator.login, null)
  administrator_password = try(local.authentication.administrator.password, null)

  storage_mb   = var.server.storage == null ? null : var.server.storage.storage_mb
  storage_tier = var.server.storage == null ? null : var.server.storage.storage_tier

  backup_retention_days        = var.server.backup == null ? null : var.server.backup.retention_days
  geo_redundant_backup_enabled = var.server.backup == null ? null : var.server.backup.geo_redundant_backup_enabled

  public_network_access_enabled = local.public_network_access_enabled
  delegated_subnet_id           = local.network.delegated_subnet_id
  private_dns_zone_id           = local.network.private_dns_zone_id

  zone = var.server.zone

  create_mode                       = var.server.create_mode != null && var.server.create_mode.mode != null ? var.server.create_mode.mode : "Default"
  source_server_id                  = var.server.create_mode == null ? null : var.server.create_mode.source_server_id
  point_in_time_restore_time_in_utc = var.server.create_mode == null ? null : var.server.create_mode.point_in_time_restore_time_in_utc

  dynamic "authentication" {
    for_each = var.authentication == null ? [] : [local.authentication]
    content {
      active_directory_auth_enabled = authentication.value.active_directory_auth_enabled
      password_auth_enabled         = authentication.value.password_auth_enabled
      tenant_id                     = authentication.value.tenant_id
    }
  }

  dynamic "high_availability" {
    for_each = var.server.high_availability != null ? [var.server.high_availability] : []
    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = high_availability.value.standby_availability_zone
    }
  }

  dynamic "maintenance_window" {
    for_each = var.server.maintenance_window != null ? [var.server.maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  dynamic "identity" {
    for_each = local.identity.type != null ? [local.identity] : []
    content {
      type         = identity.value.type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], identity.value.type) ? identity.value.identity_ids : null
    }
  }

  dynamic "customer_managed_key" {
    for_each = local.encryption != null ? [local.encryption] : []
    content {
      key_vault_key_id                     = customer_managed_key.value.key_vault_key_id
      primary_user_assigned_identity_id    = customer_managed_key.value.primary_user_assigned_identity_id
      geo_backup_key_vault_key_id          = customer_managed_key.value.geo_backup_key_vault_key_id
      geo_backup_user_assigned_identity_id = customer_managed_key.value.geo_backup_user_assigned_identity_id
    }
  }

  dynamic "timeouts" {
    for_each = var.server.timeouts != null ? [var.server.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = var.tags

}

resource "azurerm_postgresql_flexible_server_configuration" "configurations" {
  for_each = { for cfg in local.features.configurations : cfg.name => cfg }

  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  value     = each.value.value
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "firewall_rules" {
  for_each = { for rule in local.network.firewall_rules : rule.name => rule }

  name             = each.value.name
  server_id        = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "active_directory_administrator" {
  count = local.authentication.active_directory_administrator != null ? 1 : 0

  server_name         = azurerm_postgresql_flexible_server.postgresql_flexible_server.name
  resource_group_name = var.resource_group_name
  tenant_id = local.authentication.active_directory_administrator == null ? null : (
    local.authentication.active_directory_administrator.tenant_id != null ? local.authentication.active_directory_administrator.tenant_id : local.authentication.tenant_id
  )
  object_id      = local.authentication.active_directory_administrator == null ? null : local.authentication.active_directory_administrator.object_id
  principal_name = local.authentication.active_directory_administrator == null ? null : local.authentication.active_directory_administrator.principal_name
  principal_type = local.authentication.active_directory_administrator == null ? null : local.authentication.active_directory_administrator.principal_type
}

resource "azurerm_postgresql_flexible_server_virtual_endpoint" "virtual_endpoints" {
  for_each = { for ve in local.features.virtual_endpoints : ve.name => ve }

  name              = each.value.name
  source_server_id  = coalesce(each.value.source_server_id, azurerm_postgresql_flexible_server.postgresql_flexible_server.id)
  replica_server_id = coalesce(each.value.replica_server_id, azurerm_postgresql_flexible_server.postgresql_flexible_server.id)
  type              = each.value.type
}

resource "azurerm_postgresql_flexible_server_backup" "backups" {
  for_each = { for backup in local.features.backups : backup.name => backup }

  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
}
