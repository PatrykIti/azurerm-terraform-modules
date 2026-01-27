# Core PostgreSQL Flexible Server Variables
variable "name" {
  description = <<-EOT
    Name of the PostgreSQL Flexible Server.
    Must be globally unique. 3-63 chars, lowercase letters, numbers, and hyphens.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "PostgreSQL Flexible Server name must be 3-63 characters long, contain only lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen."
  }
}

variable "resource_group_name" {
  description = <<-EOT
    Resource group name where the server and server-scoped resources are created.
    The resource group must already exist.
  EOT
  type        = string
}

variable "location" {
  description = <<-EOT
    Azure region for the server and all resources created by this module.
    Typically match the resource group location.
  EOT
  type        = string
}

# Server Configuration
variable "server" {
  description = <<-EOT
    Core PostgreSQL Flexible Server configuration.

    sku_name: SKU for the server (e.g. GP_Standard_D2s_v3).
    postgresql_version: PostgreSQL major version for the server.
    zone: Availability zone for the primary server.

    storage: Storage settings for the server (storage_mb, storage_tier, auto_grow_enabled).
    backup: Backup retention and geo-redundancy settings.
    encryption: Customer-managed key settings for the server.
    high_availability: High availability settings.
    maintenance_window: Maintenance window in UTC.
    create_mode: Create/restore/replica mode settings.
    replication_role: Replication role for the server (set only with create_mode = Update).
    timeouts: Custom timeouts for create, update, delete.
  EOT

  type = object({
    sku_name           = string
    postgresql_version = string
    zone               = optional(string)

    storage = optional(object({
      storage_mb        = optional(number)
      storage_tier      = optional(string)
      auto_grow_enabled = optional(bool)
    }), {})

    backup = optional(object({
      retention_days               = optional(number, 7)
      geo_redundant_backup_enabled = optional(bool, false)
    }), {})

    encryption = optional(object({
      key_vault_key_id                     = string
      primary_user_assigned_identity_id    = string
      geo_backup_key_vault_key_id          = optional(string)
      geo_backup_user_assigned_identity_id = optional(string)
    }))

    high_availability = optional(object({
      mode                      = string
      standby_availability_zone = optional(string)
    }))

    maintenance_window = optional(object({
      day_of_week  = number
      start_hour   = number
      start_minute = number
    }))

    create_mode = optional(object({
      mode                              = optional(string)
      source_server_id                  = optional(string)
      point_in_time_restore_time_in_utc = optional(string)
    }), {})

    replication_role = optional(string)

    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = length(var.server.sku_name) > 0
    error_message = "server.sku_name must be a non-empty string."
  }

  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16", "17", "18"], var.server.postgresql_version)
    error_message = "server.postgresql_version must be one of: 11, 12, 13, 14, 15, 16, 17, 18."
  }

  validation {
    condition = var.server.storage == null ? true : (
      var.server.storage.storage_mb == null || (
        var.server.storage.storage_mb >= 32768 &&
        var.server.storage.storage_mb <= 33553408 &&
        var.server.storage.storage_mb == floor(var.server.storage.storage_mb)
      )
    )
    error_message = "server.storage.storage_mb must be an integer between 32768 and 33553408 when set."
  }

  validation {
    condition = var.server.storage == null ? true : (
      var.server.storage.storage_tier == null || contains([
        "P4",
        "P6",
        "P10",
        "P15",
        "P20",
        "P30",
        "P40",
        "P50",
        "P60",
        "P70",
        "P80"
      ], var.server.storage.storage_tier)
    )
    error_message = "server.storage.storage_tier must be one of: P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80."
  }

  validation {
    condition     = var.server.replication_role == null || contains(["None"], var.server.replication_role)
    error_message = "server.replication_role must be \"None\" when set."
  }

  validation {
    condition = var.server.replication_role == null || (
      (var.server.create_mode != null && var.server.create_mode.mode != null ? var.server.create_mode.mode : "Default") == "Update"
    )
    error_message = "server.replication_role can only be set when create_mode is Update."
  }

  validation {
    condition     = var.server.backup == null ? true : (var.server.backup.retention_days >= 7 && var.server.backup.retention_days <= 35)
    error_message = "server.backup.retention_days must be between 7 and 35."
  }

  validation {
    condition = var.server.backup == null ? true : (
      !var.server.backup.geo_redundant_backup_enabled ||
      var.server.encryption == null ||
      (
        var.server.encryption.geo_backup_key_vault_key_id != null &&
        var.server.encryption.geo_backup_user_assigned_identity_id != null
      )
    )
    error_message = "server.backup.geo_redundant_backup_enabled with server.encryption requires geo_backup_key_vault_key_id and geo_backup_user_assigned_identity_id."
  }

  validation {
    condition = var.server.encryption == null || (
      var.identity != null && contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    )
    error_message = "server.encryption requires identity.type to include UserAssigned."
  }

  validation {
    condition = var.server.encryption == null || (
      var.identity != null &&
      var.identity.identity_ids != null &&
      contains(var.identity.identity_ids, var.server.encryption.primary_user_assigned_identity_id)
    )
    error_message = "server.encryption.primary_user_assigned_identity_id must be included in identity.identity_ids."
  }

  validation {
    condition     = var.server.encryption == null || var.server.encryption.geo_backup_key_vault_key_id == null || var.server.encryption.geo_backup_user_assigned_identity_id != null
    error_message = "server.encryption.geo_backup_user_assigned_identity_id is required when geo_backup_key_vault_key_id is set."
  }

  validation {
    condition     = var.server.high_availability == null || contains(["ZoneRedundant", "SameZone"], var.server.high_availability.mode)
    error_message = "server.high_availability.mode must be one of: ZoneRedundant, SameZone."
  }

  validation {
    condition     = var.server.high_availability == null || var.server.high_availability.standby_availability_zone == null || var.server.high_availability.mode == "ZoneRedundant"
    error_message = "server.high_availability.standby_availability_zone is only valid when high_availability.mode is ZoneRedundant."
  }

  validation {
    condition = var.server.maintenance_window == null || (
      var.server.maintenance_window.day_of_week >= 0 && var.server.maintenance_window.day_of_week <= 6 &&
      var.server.maintenance_window.start_hour >= 0 && var.server.maintenance_window.start_hour <= 23 &&
      var.server.maintenance_window.start_minute >= 0 && var.server.maintenance_window.start_minute <= 59
    )
    error_message = "server.maintenance_window values must be within day_of_week 0-6, start_hour 0-23, start_minute 0-59."
  }

  validation {
    condition = var.server.create_mode == null ? true : (
      var.server.create_mode.mode == null || contains([
        "Default",
        "PointInTimeRestore",
        "Replica",
        "ReviveDropped",
        "GeoRestore",
        "Update"
      ], var.server.create_mode.mode)
    )
    error_message = "server.create_mode.mode must be one of: Default, PointInTimeRestore, Replica, ReviveDropped, GeoRestore, Update."
  }

  validation {
    condition = (var.server.create_mode != null && var.server.create_mode.mode != null ? var.server.create_mode.mode : "Default") != "Default" || (
      (var.server.create_mode == null || var.server.create_mode.source_server_id == null) &&
      (var.server.create_mode == null || var.server.create_mode.point_in_time_restore_time_in_utc == null)
    )
    error_message = "server.create_mode.source_server_id and server.create_mode.point_in_time_restore_time_in_utc must be null when create_mode is Default."
  }

  validation {
    condition = !contains([
      "Replica",
      "PointInTimeRestore",
      "GeoRestore",
      "ReviveDropped"
      ], (var.server.create_mode != null && var.server.create_mode.mode != null ? var.server.create_mode.mode : "Default")) || (
      var.server.create_mode != null && var.server.create_mode.source_server_id != null
    )
    error_message = "server.create_mode.source_server_id is required when create_mode is Replica, PointInTimeRestore, GeoRestore, or ReviveDropped."
  }

  validation {
    condition = (var.server.create_mode != null && var.server.create_mode.mode != null ? var.server.create_mode.mode : "Default") != "PointInTimeRestore" || (
      var.server.create_mode != null && var.server.create_mode.point_in_time_restore_time_in_utc != null
    )
    error_message = "server.create_mode.point_in_time_restore_time_in_utc is required when create_mode is PointInTimeRestore."
  }

  validation {
    condition = (
      (var.server.create_mode == null || var.server.create_mode.point_in_time_restore_time_in_utc == null) ||
      (var.server.create_mode != null && var.server.create_mode.mode != null ? var.server.create_mode.mode : "Default") == "PointInTimeRestore"
    )
    error_message = "server.create_mode.point_in_time_restore_time_in_utc is only valid when create_mode is PointInTimeRestore."
  }
}

# Authentication
variable "authentication" {
  description = <<-EOT
    Authentication settings for the server.
    At least one method must be enabled.

    password_auth_enabled: Enable local password authentication.
    administrator: Administrator login and password for password auth (password or password_wo).

    active_directory_auth_enabled: Enable Entra ID authentication.
    tenant_id: Tenant ID for Entra ID (can be specified here or in the admin block).
    active_directory_administrator: Administrator configuration for Entra ID.
  EOT

  type = object({
    active_directory_auth_enabled = optional(bool, false)
    password_auth_enabled         = optional(bool, true)
    tenant_id                     = optional(string)

    administrator = optional(object({
      login               = string
      password            = optional(string)
      password_wo         = optional(string)
      password_wo_version = optional(number)
    }))

    active_directory_administrator = optional(object({
      principal_name = string
      object_id      = string
      principal_type = string
      tenant_id      = optional(string)
    }))
  })

  nullable  = false
  default   = {}
  sensitive = true

  validation {
    condition = var.authentication == null ? true : (
      var.authentication.active_directory_auth_enabled || var.authentication.password_auth_enabled
    )
    error_message = "At least one authentication method must be enabled (active_directory_auth_enabled or password_auth_enabled)."
  }

  validation {
    condition = var.authentication == null ? true : (
      !var.authentication.active_directory_auth_enabled ||
      (
        var.authentication.active_directory_administrator != null &&
        (
          (var.authentication.tenant_id != null && var.authentication.tenant_id != "") ||
          (var.authentication.active_directory_administrator.tenant_id != null && var.authentication.active_directory_administrator.tenant_id != "")
        )
      )
    )
    error_message = "authentication.active_directory_administrator and authentication.tenant_id or authentication.active_directory_administrator.tenant_id are required when active_directory_auth_enabled is true."
  }

  validation {
    condition     = var.authentication == null || var.authentication.active_directory_administrator == null || var.authentication.active_directory_auth_enabled
    error_message = "authentication.active_directory_administrator requires authentication.active_directory_auth_enabled = true."
  }

  validation {
    condition     = var.authentication == null || var.authentication.active_directory_administrator == null || contains(["Group", "ServicePrincipal", "User"], var.authentication.active_directory_administrator.principal_type)
    error_message = "authentication.active_directory_administrator.principal_type must be one of: Group, ServicePrincipal, User."
  }

  validation {
    condition = var.authentication == null || var.authentication.administrator == null || (
      length(var.authentication.administrator.login) >= 1 && length(var.authentication.administrator.login) <= 63
    )
    error_message = "authentication.administrator.login must be between 1 and 63 characters when set."
  }

  validation {
    condition = var.authentication == null || var.authentication.administrator == null || (
      var.authentication.administrator.password == null ||
      (length(var.authentication.administrator.password) >= 8 && length(var.authentication.administrator.password) <= 128)
    )
    error_message = "authentication.administrator.password must be between 8 and 128 characters when set."
  }

  validation {
    condition = var.authentication == null || var.authentication.administrator == null || (
      var.authentication.administrator.password_wo == null ||
      (length(var.authentication.administrator.password_wo) >= 8 && length(var.authentication.administrator.password_wo) <= 128)
    )
    error_message = "authentication.administrator.password_wo must be between 8 and 128 characters when set."
  }

  validation {
    condition = var.authentication == null || var.authentication.administrator == null || (
      var.authentication.administrator.password_wo_version == null ||
      (
        var.authentication.administrator.password_wo_version >= 0 &&
        var.authentication.administrator.password_wo_version == floor(var.authentication.administrator.password_wo_version)
      )
    )
    error_message = "authentication.administrator.password_wo_version must be a non-negative integer when set."
  }

  validation {
    condition = var.authentication == null || var.authentication.administrator == null || (
      var.authentication.administrator.password_wo_version == null ||
      var.authentication.administrator.password_wo != null
    )
    error_message = "authentication.administrator.password_wo_version requires authentication.administrator.password_wo to be set."
  }

  validation {
    condition = var.authentication == null || var.authentication.administrator == null || (
      var.authentication.administrator.password_wo == null ||
      var.authentication.administrator.password_wo_version != null
    )
    error_message = "authentication.administrator.password_wo requires authentication.administrator.password_wo_version to be set."
  }

  validation {
    condition = var.authentication == null || var.authentication.administrator == null || !(
      var.authentication.administrator.password != null &&
      var.authentication.administrator.password_wo != null
    )
    error_message = "authentication.administrator.password and authentication.administrator.password_wo cannot both be set."
  }

  validation {
    condition = (
      (var.server.create_mode != null && var.server.create_mode.mode != null ? var.server.create_mode.mode : "Default") != "Default" ||
      (var.authentication == null ? true : !var.authentication.password_auth_enabled) ||
      (
        var.authentication != null &&
        var.authentication.administrator != null &&
        var.authentication.administrator.login != "" &&
        (
          (var.authentication.administrator.password != null && var.authentication.administrator.password != "") ||
          (var.authentication.administrator.password_wo != null && var.authentication.administrator.password_wo != "")
        )
      )
    )
    error_message = "authentication.administrator.login and password/password_wo are required when create_mode is Default and password authentication is enabled."
  }
}

# Network
variable "network" {
  description = <<-EOT
    Network settings for the server.
    By default public access is enabled. Set public_network_access_enabled = false
    to disable public access. When using delegated subnet private access, provide
    both delegated_subnet_id and private_dns_zone_id (they must be set together).
    Private endpoints can be managed externally when public access is disabled.

    firewall_rules are only valid when public network access is enabled.
  EOT

  type = object({
    public_network_access_enabled = optional(bool, true)
    delegated_subnet_id           = optional(string)
    private_dns_zone_id           = optional(string)
    firewall_rules = optional(list(object({
      name             = string
      start_ip_address = string
      end_ip_address   = string
    })), [])
  })

  nullable = false
  default  = {}

  validation {
    condition = var.network == null ? true : (
      (var.network.delegated_subnet_id == null && var.network.private_dns_zone_id == null) ||
      (var.network.delegated_subnet_id != null && var.network.private_dns_zone_id != null)
    )
    error_message = "network.delegated_subnet_id and network.private_dns_zone_id must be set together."
  }

  validation {
    condition = var.network == null ? true : (
      (var.network.delegated_subnet_id == null && var.network.private_dns_zone_id == null) ||
      var.network.public_network_access_enabled == false
    )
    error_message = "network.delegated_subnet_id/private_dns_zone_id require public_network_access_enabled = false."
  }

  validation {
    condition     = length(try(var.network.firewall_rules, [])) == length(distinct([for rule in try(var.network.firewall_rules, []) : rule.name]))
    error_message = "firewall rule names must be unique."
  }

  validation {
    condition = alltrue([
      for rule in try(var.network.firewall_rules, []) :
      can(regex("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", rule.start_ip_address)) &&
      can(regex("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", rule.end_ip_address))
    ])
    error_message = "network.firewall_rules start_ip_address and end_ip_address must be valid IPv4 addresses."
  }

  validation {
    condition = length(try(var.network.firewall_rules, [])) == 0 || (
      var.network == null ? true : (
        var.network.public_network_access_enabled != null
        ? var.network.public_network_access_enabled
        : !(
          (var.network.delegated_subnet_id != null) ||
          (var.network.private_dns_zone_id != null)
        )
      )
    )
    error_message = "network.firewall_rules require public_network_access_enabled = true."
  }
}

# Identity
variable "identity" {
  description = <<-EOT
    Managed identity configuration.

    type can be SystemAssigned, UserAssigned, or both. When UserAssigned is
    included, identity_ids must be provided.
  EOT

  type = object({
    type         = string
    identity_ids = optional(list(string))
  })

  default = null

  validation {
    condition     = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "identity.type must be one of: SystemAssigned, UserAssigned, or \"SystemAssigned, UserAssigned\"."
  }

  validation {
    condition = var.identity == null ? true : (
      var.identity.identity_ids == null || length(var.identity.identity_ids) == 0 ||
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    )
    error_message = "identity.identity_ids can only be set when identity.type includes UserAssigned."
  }

  validation {
    condition = var.identity == null ? true : (
      !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) ||
      (var.identity.identity_ids != null && length(var.identity.identity_ids) > 0)
    )
    error_message = "identity.identity_ids must be provided when identity.type includes UserAssigned."
  }

}

# Features
variable "features" {
  description = <<-EOT
    Additional PostgreSQL Flexible Server features.

    configurations: List of server configuration name/value pairs.
    virtual_endpoints: Virtual endpoints for replicas.
    backups: Manual backup definitions.
  EOT

  type = object({
    configurations = optional(list(object({
      name  = string
      value = string
    })), [])

    virtual_endpoints = optional(list(object({
      name              = string
      source_server_id  = optional(string)
      replica_server_id = optional(string)
      type              = optional(string, "ReadWrite")
    })), [])

    backups = optional(list(object({
      name = string
    })), [])
  })

  nullable = false
  default  = {}

  validation {
    condition     = length(try(var.features.configurations, [])) == length(distinct([for cfg in try(var.features.configurations, []) : cfg.name]))
    error_message = "configuration names must be unique."
  }

  validation {
    condition = alltrue([
      for cfg in try(var.features.configurations, []) :
      length(cfg.name) > 0
    ])
    error_message = "configuration names must not be empty."
  }

  validation {
    condition     = length(try(var.features.virtual_endpoints, [])) == length(distinct([for ve in try(var.features.virtual_endpoints, []) : ve.name]))
    error_message = "virtual endpoint names must be unique."
  }

  validation {
    condition = alltrue([
      for ve in try(var.features.virtual_endpoints, []) :
      contains(["ReadWrite"], ve.type)
    ])
    error_message = "features.virtual_endpoints.type must be ReadWrite."
  }

  validation {
    condition = alltrue([
      for ve in try(var.features.virtual_endpoints, []) :
      ve.source_server_id != null || ve.replica_server_id != null
    ])
    error_message = "features.virtual_endpoints entries must set at least one of source_server_id or replica_server_id."
  }

  validation {
    condition     = length(try(var.features.backups, [])) == length(distinct([for backup in try(var.features.backups, []) : backup.name]))
    error_message = "backup names must be unique."
  }
}

# Monitoring
variable "monitoring" {
  description = <<-EOT
    Monitoring configuration for PostgreSQL Flexible Server.

    Diagnostic settings for logs and metrics. Provide explicit log_categories
    and/or metric_categories and at least one destination (Log Analytics,
    Storage, or Event Hub).
  EOT

  type = list(object({
    name                           = string
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
  }))

  nullable = false
  default  = []

  validation {
    condition     = length(var.monitoring) <= 5
    error_message = "Azure allows a maximum of 5 diagnostic settings per PostgreSQL Flexible Server."
  }

  validation {
    condition     = length(distinct([for ds in var.monitoring : ds.name])) == length(var.monitoring)
    error_message = "Each monitoring entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for ds in var.monitoring :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "Each monitoring entry must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
  }

  validation {
    condition = alltrue([
      for ds in var.monitoring :
      ds.eventhub_authorization_rule_id == null || (ds.eventhub_name != null && ds.eventhub_name != "")
    ])
    error_message = "eventhub_name is required when eventhub_authorization_rule_id is set."
  }

  validation {
    condition = alltrue([
      for ds in var.monitoring :
      ds.log_analytics_destination_type == null || contains(["Dedicated", "AzureDiagnostics"], ds.log_analytics_destination_type)
    ])
    error_message = "log_analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }

  validation {
    condition = alltrue([
      for ds in var.monitoring :
      alltrue([for c in(ds.log_categories == null ? [] : ds.log_categories) : c != ""]) &&
      alltrue([for c in(ds.metric_categories == null ? [] : ds.metric_categories) : c != ""])
    ])
    error_message = "log_categories and metric_categories must not contain empty strings."
  }
}

# Tags
variable "tags" {
  description = <<-EOT
    Tags to apply to the server.
    Provide a map of string keys and values.
  EOT
  type        = map(string)
  default     = {}
}
