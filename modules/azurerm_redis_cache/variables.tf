# Core
variable "name" {
  description = "The name of the Redis Cache."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$", var.name))
    error_message = "name must be 1-63 characters, contain only letters, numbers, and hyphens, and start/end with an alphanumeric character."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Redis Cache."
  type        = string
}

variable "location" {
  description = "The Azure region where the Redis Cache should be created."
  type        = string
}

# SKU
variable "sku_name" {
  description = "The SKU name of the Redis Cache. Possible values: Basic, Standard, Premium."
  type        = string

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "sku_name must be one of: Basic, Standard, Premium."
  }
}

variable "family" {
  description = "The SKU family. Possible values: C (Basic/Standard) or P (Premium)."
  type        = string

  validation {
    condition     = contains(["C", "P"], var.family)
    error_message = "family must be either C or P."
  }
}

variable "capacity" {
  description = "The SKU capacity. Valid ranges depend on sku_name/family."
  type        = number

  validation {
    condition     = var.capacity >= 0
    error_message = "capacity must be a non-negative number."
  }

  validation {
    condition = (
      (var.sku_name == "Premium" && var.family == "P" && var.capacity >= 1 && var.capacity <= 5) ||
      ((var.sku_name == "Basic" || var.sku_name == "Standard") && var.family == "C" && var.capacity >= 0 && var.capacity <= 6)
    )
    error_message = "sku_name/family/capacity must be Basic/Standard with family C and capacity 0-6, or Premium with family P and capacity 1-5."
  }
}

# Network
variable "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "The ID of the subnet to deploy the Redis Cache into (Premium only)."
  type        = string
  default     = null

  validation {
    condition     = var.subnet_id == null || trimspace(var.subnet_id) == "" || var.sku_name == "Premium"
    error_message = "subnet_id is only supported with Premium SKU."
  }

  validation {
    condition = (
      var.subnet_id == null || trimspace(var.subnet_id) == ""
      ) == (
      var.private_static_ip_address == null || trimspace(var.private_static_ip_address) == ""
    )
    error_message = "subnet_id and private_static_ip_address must be set together."
  }

  validation {
    condition     = var.subnet_id == null || trimspace(var.subnet_id) == "" || var.public_network_access_enabled == false
    error_message = "public_network_access_enabled must be false when subnet_id is set."
  }
}

variable "private_static_ip_address" {
  description = "The static IP address for the Redis Cache when using subnet injection (Premium only)."
  type        = string
  default     = null
}

# Security
variable "minimum_tls_version" {
  description = "The minimum TLS version. Possible values: 1.0, 1.1, 1.2."
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be one of: 1.0, 1.1, 1.2."
  }
}

variable "non_ssl_port_enabled" {
  description = "Whether the non-SSL port (6379) is enabled."
  type        = bool
  default     = false
}

variable "access_keys_authentication_enabled" {
  description = "Whether access key authentication is enabled. When disabled, Active Directory authentication must be enabled in redis_configuration."
  type        = bool
  default     = true

  validation {
    condition = var.access_keys_authentication_enabled || (
      var.redis_configuration != null &&
      coalesce(var.redis_configuration.active_directory_authentication_enabled, false)
    )
    error_message = "When access_keys_authentication_enabled is false, redis_configuration.active_directory_authentication_enabled must be true."
  }
}

# Availability and scale
variable "zones" {
  description = "The availability zones in which to deploy the Redis Cache."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "redis_version" {
  description = "The Redis version. Possible values: 4, 6."
  type        = string
  default     = "6"

  validation {
    condition     = contains(["4", "6"], var.redis_version)
    error_message = "redis_version must be one of: 4, 6."
  }
}

variable "shard_count" {
  description = "The number of shards (Premium only)."
  type        = number
  default     = null

  validation {
    condition     = var.shard_count == null || var.sku_name == "Premium"
    error_message = "shard_count is only supported with Premium SKU."
  }
}

variable "replicas_per_primary" {
  description = "The number of replicas per primary (Premium only)."
  type        = number
  default     = null

  validation {
    condition = (
      var.replicas_per_primary == null && var.replicas_per_master == null
      ) || (
      var.sku_name == "Premium"
    )
    error_message = "replicas_per_master/replicas_per_primary are only supported with Premium SKU."
  }

  validation {
    condition = var.shard_count == null || (
      var.replicas_per_primary == null && var.replicas_per_master == null
    )
    error_message = "replicas_per_master/replicas_per_primary cannot be used with shard_count."
  }

  validation {
    condition     = var.replicas_per_primary == null || var.replicas_per_master == null
    error_message = "replicas_per_master and replicas_per_primary are mutually exclusive; set only one."
  }
}

variable "replicas_per_master" {
  description = "The number of replicas per master (Premium only)."
  type        = number
  default     = null
}

# Redis configuration
variable "redis_configuration" {
  description = <<-EOT
    Redis configuration settings.

    Note: maxclients is computed by the provider and cannot be set.
  EOT

  type = object({
    active_directory_authentication_enabled = optional(bool)
    aof_backup_enabled                      = optional(bool)
    aof_storage_connection_string_0         = optional(string)
    aof_storage_connection_string_1         = optional(string)
    authentication_enabled                  = optional(bool)
    data_persistence_authentication_method  = optional(string)
    maxfragmentationmemory_reserved         = optional(number)
    maxmemory_delta                         = optional(number)
    maxmemory_policy                        = optional(string)
    maxmemory_reserved                      = optional(number)
    notify_keyspace_events                  = optional(string)
    rdb_backup_enabled                      = optional(bool)
    rdb_backup_frequency                    = optional(number)
    rdb_backup_max_snapshot_count           = optional(number)
    rdb_storage_connection_string           = optional(string)
    storage_account_subscription_id         = optional(string)
  })

  default = null

  validation {
    condition = var.redis_configuration == null || !coalesce(var.redis_configuration.aof_backup_enabled, false) || (
      try(trimspace(var.redis_configuration.aof_storage_connection_string_0), "") != "" ||
      try(trimspace(var.redis_configuration.aof_storage_connection_string_1), "") != ""
    )
    error_message = "aof_storage_connection_string_0 or aof_storage_connection_string_1 must be set when aof_backup_enabled is true."
  }

  validation {
    condition = var.redis_configuration == null || !coalesce(var.redis_configuration.rdb_backup_enabled, false) || (
      try(trimspace(var.redis_configuration.rdb_storage_connection_string), "") != ""
    )
    error_message = "rdb_storage_connection_string must be set when rdb_backup_enabled is true."
  }

  validation {
    condition = var.redis_configuration == null || !(
      coalesce(var.redis_configuration.aof_backup_enabled, false) &&
      coalesce(var.redis_configuration.rdb_backup_enabled, false)
    )
    error_message = "aof_backup_enabled and rdb_backup_enabled cannot both be true."
  }
}

variable "tenant_settings" {
  description = "Tenant settings for the Redis Cache."
  type        = map(string)
  default     = {}
  nullable    = false
}

# Identity
variable "identity" {
  description = "Managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition = var.identity == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.identity.type)
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

# Patch schedule (Premium)
variable "patch_schedule" {
  description = "Patch schedule entries for Premium caches."
  type = list(object({
    day_of_week        = string
    start_hour_utc     = optional(number)
    maintenance_window = optional(string)
  }))

  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for ps in var.patch_schedule : contains([
        "Everyday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
      ], ps.day_of_week)
    ])
    error_message = "patch_schedule.day_of_week must be one of: Everyday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday."
  }

  validation {
    condition = alltrue([
      for ps in var.patch_schedule :
      ps.start_hour_utc == null || (ps.start_hour_utc >= 0 && ps.start_hour_utc <= 23)
    ])
    error_message = "patch_schedule.start_hour_utc must be between 0 and 23 when set."
  }

  validation {
    condition     = length(var.patch_schedule) == 0 || var.sku_name == "Premium"
    error_message = "patch_schedule is only supported with Premium SKU."
  }
}

# Firewall rules
variable "firewall_rules" {
  description = "Firewall rules for the Redis Cache (public access only)."
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for rule in var.firewall_rules : rule.name])) == length(var.firewall_rules)
    error_message = "Each firewall rule must have a unique name."
  }

  validation {
    condition     = length(var.firewall_rules) == 0 || var.public_network_access_enabled
    error_message = "firewall_rules require public_network_access_enabled = true."
  }
}

# Linked servers (Premium)
variable "linked_servers" {
  description = "Linked Redis servers (geo-replication) for Premium caches."
  type = list(object({
    name                        = string
    linked_redis_cache_id       = string
    linked_redis_cache_location = string
    server_role                 = string
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for ls in var.linked_servers : ls.name])) == length(var.linked_servers)
    error_message = "Each linked server entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for ls in var.linked_servers : contains(["Primary", "Secondary"], ls.server_role)
    ])
    error_message = "linked_servers.server_role must be Primary or Secondary."
  }

  validation {
    condition     = length(var.linked_servers) == 0 || var.sku_name == "Premium"
    error_message = "linked_servers are only supported with Premium SKU."
  }
}

# Diagnostic settings
variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for Redis Cache logs and metrics.

    Provide explicit log_categories and/or metric_categories and at least one destination.
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

  default  = []
  nullable = false

  validation {
    condition     = length(var.diagnostic_settings) <= 5
    error_message = "Azure allows a maximum of 5 diagnostic settings per Redis Cache resource."
  }

  validation {
    condition     = length(distinct([for ds in var.diagnostic_settings : ds.name])) == length(var.diagnostic_settings)
    error_message = "Each diagnostic setting must have a unique name."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "Each diagnostic setting must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
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
  description = "Tags to apply to the Redis Cache."
  type        = map(string)
  default     = {}
  nullable    = false
}

# Timeouts
variable "timeouts" {
  description = "Timeouts for Redis Cache operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
