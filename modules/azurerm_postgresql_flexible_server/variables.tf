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

variable "sku_name" {
  description = <<-EOT
    SKU for the server (e.g. GP_Standard_D2s_v3).
    Must be supported in the selected region and for the chosen version.
  EOT
  type        = string

  validation {
    condition     = length(var.sku_name) > 0
    error_message = "sku_name must be a non-empty string."
  }
}

variable "postgresql_version" {
  description = <<-EOT
    PostgreSQL major version for the server.
    Allowed values are validated; choose a version supported in the region.
  EOT
  type        = string

  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16", "17", "18"], var.postgresql_version)
    error_message = "postgresql_version must be one of: 11, 12, 13, 14, 15, 16, 17, 18."
  }
}

variable "administrator_login" {
  description = <<-EOT
    Local administrator login for password authentication.
    Required when create_mode is Default and password_auth_enabled is true.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.administrator_login == null || (length(var.administrator_login) >= 1 && length(var.administrator_login) <= 63)
    error_message = "administrator_login must be between 1 and 63 characters when set."
  }
}

variable "administrator_password" {
  description = <<-EOT
    Local administrator password for password authentication.
    Required when create_mode is Default and password_auth_enabled is true.
  EOT
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.administrator_password == null || (length(var.administrator_password) >= 8 && length(var.administrator_password) <= 128)
    error_message = "administrator_password must be between 8 and 128 characters when set."
  }

  validation {
    condition = (
      (var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default") != "Default" ||
      (var.authentication == null ? true : !var.authentication.password_auth_enabled) ||
      (var.administrator_login != null && var.administrator_login != "" && var.administrator_password != null && var.administrator_password != "")
    )
    error_message = "administrator_login and administrator_password are required when create_mode is Default and password authentication is enabled."
  }
}

variable "storage" {
  description = <<-EOT
    Storage settings for the server.
    Leave empty to use Azure defaults. storage_mb is in MB; storage_tier must be valid.
  EOT
  type = object({
    storage_mb   = optional(number)
    storage_tier = optional(string)
  })
  default = {}

  validation {
    condition = var.storage == null ? true : (
      var.storage.storage_mb == null || (
        var.storage.storage_mb >= 32768 &&
        var.storage.storage_mb <= 33553408 &&
        var.storage.storage_mb == floor(var.storage.storage_mb)
      )
    )
    error_message = "storage.storage_mb must be an integer between 32768 and 33553408 when set."
  }

  validation {
    condition = var.storage == null ? true : (
      var.storage.storage_tier == null || contains([
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
      ], var.storage.storage_tier)
    )
    error_message = "storage.storage_tier must be one of: P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80."
  }
}

variable "backup" {
  description = <<-EOT
    Backup settings for the server.
    retention_days must be 7-35. geo_redundant_backup_enabled controls GRS backups.
  EOT
  type = object({
    retention_days               = optional(number, 7)
    geo_redundant_backup_enabled = optional(bool, false)
  })
  default = {}

  validation {
    condition     = var.backup == null ? true : (var.backup.retention_days >= 7 && var.backup.retention_days <= 35)
    error_message = "backup.retention_days must be between 7 and 35."
  }
}

variable "network" {
  description = <<-EOT
    Network settings for the server.
    By default public access is enabled. For private access set
    public_network_access_enabled = false and provide both delegated_subnet_id
    and private_dns_zone_id.
  EOT
  type = object({
    public_network_access_enabled = optional(bool)
    delegated_subnet_id           = optional(string)
    private_dns_zone_id           = optional(string)
  })
  default = {}

  validation {
    condition = var.network == null ? true : (
      (var.network.public_network_access_enabled == false ||
        var.network.delegated_subnet_id != null ||
        var.network.private_dns_zone_id != null
      )
      ? (var.network.delegated_subnet_id != null && var.network.private_dns_zone_id != null)
      : true
    )
    error_message = "network.delegated_subnet_id and network.private_dns_zone_id are required when public_network_access_enabled is false or when private networking is configured."
  }

  validation {
    condition = var.network == null ? true : (
      var.network.public_network_access_enabled != true ||
      (var.network.delegated_subnet_id == null && var.network.private_dns_zone_id == null)
    )
    error_message = "network.delegated_subnet_id/private_dns_zone_id require public_network_access_enabled = false."
  }
}

variable "authentication" {
  description = <<-EOT
    Authentication settings for the server.
    At least one method must be enabled. For Entra ID (AAD) set
    active_directory_auth_enabled = true and provide active_directory_administrator
    plus tenant_id (here or in the admin block).
  EOT
  type = object({
    active_directory_auth_enabled = optional(bool, false)
    password_auth_enabled         = optional(bool, true)
    tenant_id                     = optional(string)
  })
  default = {}

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
        var.active_directory_administrator != null &&
        (
          (var.authentication.tenant_id != null && var.authentication.tenant_id != "") ||
          (var.active_directory_administrator.tenant_id != null && var.active_directory_administrator.tenant_id != "")
        )
      )
    )
    error_message = "active_directory_administrator and authentication.tenant_id or active_directory_administrator.tenant_id are required when active_directory_auth_enabled is true."
  }

  validation {
    condition     = var.active_directory_administrator == null || (var.authentication != null && var.authentication.active_directory_auth_enabled)
    error_message = "active_directory_administrator requires authentication.active_directory_auth_enabled = true."
  }
}

variable "high_availability" {
  description = <<-EOT
    High availability settings.
    mode can be ZoneRedundant or SameZone. When ZoneRedundant,
    standby_availability_zone is optional; if omitted Azure chooses the zone
    and may update it after failover.
  EOT
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = null

  validation {
    condition     = var.high_availability == null || contains(["ZoneRedundant", "SameZone"], var.high_availability.mode)
    error_message = "high_availability.mode must be one of: ZoneRedundant, SameZone."
  }

  validation {
    condition     = var.high_availability == null || var.high_availability.standby_availability_zone == null || var.high_availability.mode == "ZoneRedundant"
    error_message = "high_availability.standby_availability_zone is only valid when high_availability.mode is ZoneRedundant."
  }
}

variable "maintenance_window" {
  description = <<-EOT
    Maintenance window in UTC.
    day_of_week is 0-6, start_hour is 0-23, start_minute is 0-59.
  EOT
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = null

  validation {
    condition = var.maintenance_window == null || (
      var.maintenance_window.day_of_week >= 0 && var.maintenance_window.day_of_week <= 6 &&
      var.maintenance_window.start_hour >= 0 && var.maintenance_window.start_hour <= 23 &&
      var.maintenance_window.start_minute >= 0 && var.maintenance_window.start_minute <= 59
    )
    error_message = "maintenance_window values must be within day_of_week 0-6, start_hour 0-23, start_minute 0-59."
  }
}

variable "zone" {
  description = <<-EOT
    Availability zone for the primary server.
    Optional; if null Azure selects a zone.
  EOT
  type        = string
  default     = null
}

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

variable "customer_managed_key" {
  description = <<-EOT
    Customer-managed key configuration using Azure Key Vault.
    Requires a user-assigned identity and a Key Vault key ID.
    primary_user_assigned_identity_id must be included in identity.identity_ids.
    Geo backup key and identity are optional.
  EOT
  type = object({
    key_vault_key_id                     = string
    primary_user_assigned_identity_id    = string
    geo_backup_key_vault_key_id          = optional(string)
    geo_backup_user_assigned_identity_id = optional(string)
  })
  default = null

  validation {
    condition = var.customer_managed_key == null || (
      var.identity != null && contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    )
    error_message = "customer_managed_key requires identity.type to include UserAssigned."
  }

  validation {
    condition = var.customer_managed_key == null || (
      var.identity != null &&
      var.identity.identity_ids != null &&
      contains(var.identity.identity_ids, var.customer_managed_key.primary_user_assigned_identity_id)
    )
    error_message = "customer_managed_key.primary_user_assigned_identity_id must be included in identity.identity_ids."
  }

  validation {
    condition     = var.customer_managed_key == null || var.customer_managed_key.geo_backup_key_vault_key_id == null || var.customer_managed_key.geo_backup_user_assigned_identity_id != null
    error_message = "customer_managed_key.geo_backup_user_assigned_identity_id is required when geo_backup_key_vault_key_id is set."
  }
}

variable "create_mode" {
  description = <<-EOT
    Create mode for the server.
    Use Default for new servers. Replica/GeoRestore/ReviveDropped/PointInTimeRestore
    require source_server_id, and PointInTimeRestore requires
    point_in_time_restore_time_in_utc.
  EOT
  type = object({
    mode                              = optional(string)
    source_server_id                  = optional(string)
    point_in_time_restore_time_in_utc = optional(string)
  })
  default = {}

  validation {
    condition = var.create_mode == null ? true : (
      var.create_mode.mode == null || contains([
        "Default",
        "PointInTimeRestore",
        "Replica",
        "ReviveDropped",
        "GeoRestore",
        "Update"
      ], var.create_mode.mode)
    )
    error_message = "create_mode.mode must be one of: Default, PointInTimeRestore, Replica, ReviveDropped, GeoRestore, Update."
  }

  validation {
    condition = (var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default") != "Default" || (
      (var.create_mode == null || var.create_mode.source_server_id == null) &&
      (var.create_mode == null || var.create_mode.point_in_time_restore_time_in_utc == null)
    )
    error_message = "source_server_id and point_in_time_restore_time_in_utc must be null when create_mode is Default."
  }

  validation {
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

  validation {
    condition = (var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default") != "PointInTimeRestore" || (
      var.create_mode != null && var.create_mode.point_in_time_restore_time_in_utc != null
    )
    error_message = "point_in_time_restore_time_in_utc is required when create_mode is PointInTimeRestore."
  }

  validation {
    condition = (
      (var.create_mode == null || var.create_mode.point_in_time_restore_time_in_utc == null) ||
      (var.create_mode != null && var.create_mode.mode != null ? var.create_mode.mode : "Default") == "PointInTimeRestore"
    )
    error_message = "point_in_time_restore_time_in_utc is only valid when create_mode is PointInTimeRestore."
  }
}

variable "timeouts" {
  description = <<-EOT
    Custom timeouts for create, update, delete (e.g. "60m").
    Leave null to use provider defaults.
  EOT
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "configurations" {
  description = <<-EOT
    List of server configuration name/value pairs.
    Names must be unique.
  EOT
  type = list(object({
    name  = string
    value = string
  }))
  default = []

  validation {
    condition     = length(var.configurations) == length(distinct([for cfg in var.configurations : cfg.name]))
    error_message = "configuration names must be unique."
  }

  validation {
    condition = alltrue([
      for cfg in var.configurations :
      length(cfg.name) > 0
    ])
    error_message = "configuration names must not be empty."
  }
}

variable "firewall_rules" {
  description = <<-EOT
    Firewall rules for public access.
    Only valid when public network access is enabled. Provide start and end IPv4 addresses.
  EOT
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []

  validation {
    condition     = length(var.firewall_rules) == length(distinct([for rule in var.firewall_rules : rule.name]))
    error_message = "firewall rule names must be unique."
  }

  validation {
    condition = alltrue([
      for rule in var.firewall_rules :
      can(regex("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", rule.start_ip_address)) &&
      can(regex("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", rule.end_ip_address))
    ])
    error_message = "firewall_rules start_ip_address and end_ip_address must be valid IPv4 addresses."
  }

  validation {
    condition = length(var.firewall_rules) == 0 || (
      var.network == null ? true : (
        var.network.public_network_access_enabled != null
        ? var.network.public_network_access_enabled
        : !(
          (var.network.delegated_subnet_id != null) ||
          (var.network.private_dns_zone_id != null)
        )
      )
    )
    error_message = "firewall_rules require public_network_access_enabled = true."
  }
}

variable "active_directory_administrator" {
  description = <<-EOT
    Entra ID administrator settings.
    Required when authentication.active_directory_auth_enabled = true. Provide
    principal_name, object_id, principal_type, and optionally tenant_id.
  EOT
  type = object({
    principal_name = string
    object_id      = string
    principal_type = string
    tenant_id      = optional(string)
  })
  default = null

  validation {
    condition     = var.active_directory_administrator == null || contains(["Group", "ServicePrincipal", "User"], var.active_directory_administrator.principal_type)
    error_message = "active_directory_administrator.principal_type must be one of: Group, ServicePrincipal, User."
  }
}

variable "virtual_endpoints" {
  description = <<-EOT
    Virtual endpoints for replicas.
    Each entry must include source_server_id or replica_server_id. type is ReadWrite.
  EOT
  type = list(object({
    name              = string
    source_server_id  = optional(string)
    replica_server_id = optional(string)
    type              = optional(string, "ReadWrite")
  }))
  default = []

  validation {
    condition     = length(var.virtual_endpoints) == length(distinct([for ve in var.virtual_endpoints : ve.name]))
    error_message = "virtual endpoint names must be unique."
  }

  validation {
    condition = alltrue([
      for ve in var.virtual_endpoints :
      contains(["ReadWrite"], ve.type)
    ])
    error_message = "virtual_endpoints.type must be ReadWrite."
  }

  validation {
    condition = alltrue([
      for ve in var.virtual_endpoints :
      ve.source_server_id != null || ve.replica_server_id != null
    ])
    error_message = "virtual_endpoints entries must set at least one of source_server_id or replica_server_id."
  }
}

variable "backups" {
  description = <<-EOT
    Manual backup definitions.
    Each entry creates a server-scoped backup with a unique name.
  EOT
  type = list(object({
    name = string
  }))
  default = []

  validation {
    condition     = length(var.backups) == length(distinct([for backup in var.backups : backup.name]))
    error_message = "backup names must be unique."
  }
}

# Diagnostic Settings
variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for PostgreSQL Flexible Server logs and metrics.
    Each item creates a separate azurerm_monitor_diagnostic_setting for the server.
    Provide explicit log_categories and/or metric_categories and at least one
    destination (Log Analytics, Storage, or Event Hub). Categories must be
    supported by Azure Monitor for this resource.
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

  default = []

  validation {
    condition     = length(var.diagnostic_settings) <= 5
    error_message = "Azure allows a maximum of 5 diagnostic settings per PostgreSQL Flexible Server."
  }

  validation {
    condition     = length(distinct([for ds in var.diagnostic_settings : ds.name])) == length(var.diagnostic_settings)
    error_message = "Each diagnostic_settings entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "Each diagnostic_settings entry must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.eventhub_authorization_rule_id == null || (ds.eventhub_name != null && ds.eventhub_name != "")
    ])
    error_message = "eventhub_name is required when eventhub_authorization_rule_id is set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_destination_type == null || contains(["Dedicated", "AzureDiagnostics"], ds.log_analytics_destination_type)
    ])
    error_message = "log_analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
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
