# Core Managed Redis Variables
variable "name" {
  description = <<-EOT
    Name of the Managed Redis instance.
    Use 1-63 characters with letters, numbers, and hyphens.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$", var.name))
    error_message = "Managed Redis name must be 1-63 characters long, contain only letters, numbers, and hyphens, and start/end with an alphanumeric character."
  }
}

variable "resource_group_name" {
  description = <<-EOT
    Name of the resource group where the Managed Redis instance and child resources are created.
    The resource group must already exist.
  EOT
  type        = string
}

variable "location" {
  description = <<-EOT
    Azure region where the Managed Redis instance is created.
    Geo-replication examples may use a different region for linked instances created outside this module.
  EOT
  type        = string
}

variable "managed_redis" {
  description = <<-EOT
    Core Managed Redis configuration.

    sku_name: Managed Redis SKU.
    high_availability_enabled: Whether HA is enabled for the cluster.
    public_network_access: Public network access mode, either Enabled or Disabled.
    timeouts: Optional custom create/read/update/delete timeouts.
  EOT

  type = object({
    sku_name                  = string
    high_availability_enabled = optional(bool, true)
    public_network_access     = optional(string, "Enabled")
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = contains([
      "Balanced_B0",
      "Balanced_B1",
      "Balanced_B3",
      "Balanced_B5",
      "Balanced_B10",
      "Balanced_B20",
      "Balanced_B50",
      "Balanced_B100",
      "Balanced_B150",
      "Balanced_B250",
      "Balanced_B350",
      "Balanced_B500",
      "Balanced_B700",
      "Balanced_B1000",
      "ComputeOptimized_X3",
      "ComputeOptimized_X5",
      "ComputeOptimized_X10",
      "ComputeOptimized_X20",
      "ComputeOptimized_X50",
      "ComputeOptimized_X100",
      "ComputeOptimized_X150",
      "ComputeOptimized_X250",
      "ComputeOptimized_X350",
      "ComputeOptimized_X500",
      "ComputeOptimized_X700",
      "FlashOptimized_A250",
      "FlashOptimized_A500",
      "FlashOptimized_A700",
      "FlashOptimized_A1000",
      "FlashOptimized_A1500",
      "FlashOptimized_A2000",
      "FlashOptimized_A4500",
      "MemoryOptimized_M10",
      "MemoryOptimized_M20",
      "MemoryOptimized_M50",
      "MemoryOptimized_M100",
      "MemoryOptimized_M150",
      "MemoryOptimized_M250",
      "MemoryOptimized_M350",
      "MemoryOptimized_M500",
      "MemoryOptimized_M700",
      "MemoryOptimized_M1000",
      "MemoryOptimized_M1500",
      "MemoryOptimized_M2000",
    ], var.managed_redis.sku_name)
    error_message = "managed_redis.sku_name must be a valid Azure Managed Redis SKU supported by azurerm 4.57.0."
  }

  validation {
    condition     = contains(["Enabled", "Disabled"], var.managed_redis.public_network_access)
    error_message = "managed_redis.public_network_access must be either Enabled or Disabled."
  }

  validation {
    condition = !(
      var.geo_replication != null ||
      (var.default_database != null && try(var.default_database.geo_replication_group_name, null) != null)
      ) || (
      !startswith(var.managed_redis.sku_name, "Balanced_B") ||
      contains([
        "Balanced_B3",
        "Balanced_B5",
        "Balanced_B10",
        "Balanced_B20",
        "Balanced_B50",
        "Balanced_B100",
        "Balanced_B150",
        "Balanced_B250",
        "Balanced_B350",
        "Balanced_B500",
        "Balanced_B700",
        "Balanced_B1000",
      ], var.managed_redis.sku_name)
    )
    error_message = "Geo-replication requires Balanced_B3 or higher when using Balanced SKUs."
  }
}

variable "default_database" {
  description = <<-EOT
    Configuration for the default Managed Redis database.

    Leave as the default empty object to create the default database with provider defaults.
    Set to null only when you intentionally want to remove the default database for troubleshooting.
  EOT

  type = object({
    access_keys_authentication_enabled            = optional(bool, false)
    client_protocol                               = optional(string, "Encrypted")
    clustering_policy                             = optional(string, "OSSCluster")
    eviction_policy                               = optional(string, "VolatileLRU")
    geo_replication_group_name                    = optional(string)
    persistence_append_only_file_backup_frequency = optional(string)
    persistence_redis_database_backup_frequency   = optional(string)
    modules = optional(list(object({
      name = string
      args = optional(string)
    })), [])
  })

  default  = {}
  nullable = true

  validation {
    condition     = var.default_database == null || contains(["Encrypted", "Plaintext"], var.default_database.client_protocol)
    error_message = "default_database.client_protocol must be either Encrypted or Plaintext."
  }

  validation {
    condition = var.default_database == null || contains([
      "EnterpriseCluster",
      "OSSCluster",
      "NoCluster",
    ], var.default_database.clustering_policy)
    error_message = "default_database.clustering_policy must be one of: EnterpriseCluster, OSSCluster, NoCluster."
  }

  validation {
    condition = var.default_database == null || contains([
      "AllKeysLFU",
      "AllKeysLRU",
      "AllKeysRandom",
      "VolatileLRU",
      "VolatileLFU",
      "VolatileTTL",
      "VolatileRandom",
      "NoEviction",
    ], var.default_database.eviction_policy)
    error_message = "default_database.eviction_policy must be a supported Azure Managed Redis eviction policy."
  }

  validation {
    condition = var.default_database == null || (
      var.default_database.persistence_append_only_file_backup_frequency == null ||
      var.default_database.persistence_append_only_file_backup_frequency == "1s"
    )
    error_message = "default_database.persistence_append_only_file_backup_frequency must be 1s when set."
  }

  validation {
    condition = var.default_database == null || (
      var.default_database.persistence_redis_database_backup_frequency == null ||
      contains(["1h", "6h", "12h"], var.default_database.persistence_redis_database_backup_frequency)
    )
    error_message = "default_database.persistence_redis_database_backup_frequency must be one of: 1h, 6h, 12h."
  }

  validation {
    condition = var.default_database == null || !(
      var.default_database.persistence_append_only_file_backup_frequency != null &&
      var.default_database.persistence_redis_database_backup_frequency != null
    )
    error_message = "Only one persistence mode can be enabled: AOF or RDB."
  }

  validation {
    condition = var.default_database == null || !(
      try(var.default_database.geo_replication_group_name, null) != null &&
      (
        var.default_database.persistence_append_only_file_backup_frequency != null ||
        var.default_database.persistence_redis_database_backup_frequency != null
      )
    )
    error_message = "Persistence cannot be enabled when default_database.geo_replication_group_name is set."
  }

  validation {
    condition     = var.default_database == null || length(try(var.default_database.modules, [])) <= 4
    error_message = "default_database.modules can contain at most 4 entries."
  }

  validation {
    condition = var.default_database == null || length(distinct([
      for redis_module in try(var.default_database.modules, []) : redis_module.name
    ])) == length(try(var.default_database.modules, []))
    error_message = "default_database.modules names must be unique."
  }

  validation {
    condition = var.default_database == null || alltrue([
      for redis_module in try(var.default_database.modules, []) :
      contains(["RedisBloom", "RedisTimeSeries", "RediSearch", "RedisJSON"], redis_module.name)
    ])
    error_message = "default_database.modules.name must be one of: RedisBloom, RedisTimeSeries, RediSearch, RedisJSON."
  }

  validation {
    condition = var.default_database == null || (
      try(var.default_database.geo_replication_group_name, null) == null ||
      alltrue([
        for redis_module in try(var.default_database.modules, []) :
        contains(["RediSearch", "RedisJSON"], redis_module.name)
      ])
    )
    error_message = "Only RediSearch and RedisJSON modules are supported with geo-replication."
  }

  validation {
    condition = var.default_database == null || (
      !contains([for redis_module in try(var.default_database.modules, []) : redis_module.name], "RediSearch") ||
      var.default_database.eviction_policy == "NoEviction"
    )
    error_message = "default_database.eviction_policy must be NoEviction when the RediSearch module is enabled."
  }

  validation {
    condition = var.default_database == null || (
      !contains([for redis_module in try(var.default_database.modules, []) : redis_module.name], "RediSearch") ||
      var.default_database.clustering_policy == "EnterpriseCluster"
    )
    error_message = "default_database.clustering_policy must be EnterpriseCluster when the RediSearch module is enabled."
  }
}

variable "identity" {
  description = <<-EOT
    Managed identity configuration for Managed Redis.

    type can be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned.
    identity_ids must be provided when the type includes UserAssigned.
  EOT

  type = object({
    type         = string
    identity_ids = optional(list(string))
  })

  default = null

  validation {
    condition = var.identity == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned",
    ], var.identity.type)
    error_message = "identity.type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }

  validation {
    condition = var.identity == null || !contains([
      "UserAssigned",
      "SystemAssigned, UserAssigned",
      ], var.identity.type) || (
      var.identity.identity_ids != null && length(var.identity.identity_ids) > 0
    )
    error_message = "identity.identity_ids is required when identity.type includes UserAssigned."
  }
}

variable "customer_managed_key" {
  description = <<-EOT
    Customer-managed key configuration for Managed Redis.

    This requires a user-assigned identity with access to the specified Key Vault key.
  EOT

  type = object({
    key_vault_key_id          = string
    user_assigned_identity_id = string
  })

  default = null

  validation {
    condition = var.customer_managed_key == null || (
      var.identity != null &&
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    )
    error_message = "customer_managed_key requires identity.type to include UserAssigned."
  }

  validation {
    condition = var.customer_managed_key == null || (
      var.identity != null &&
      var.identity.identity_ids != null &&
      contains(var.identity.identity_ids, var.customer_managed_key.user_assigned_identity_id)
    )
    error_message = "customer_managed_key.user_assigned_identity_id must be included in identity.identity_ids."
  }
}

variable "geo_replication" {
  description = <<-EOT
    Optional geo-replication membership management for this Managed Redis instance.

    The local Managed Redis instance is always the managed_redis_id.
    Provide only the linked Managed Redis IDs for the rest of the geo-replication group.
  EOT

  type = object({
    linked_managed_redis_ids = set(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  default = null

  validation {
    condition     = var.geo_replication == null || length(var.geo_replication.linked_managed_redis_ids) <= 4
    error_message = "geo_replication.linked_managed_redis_ids can contain at most 4 linked Managed Redis IDs."
  }

  validation {
    condition = var.geo_replication == null || alltrue([
      for managed_redis_id in var.geo_replication.linked_managed_redis_ids :
      trimspace(managed_redis_id) != ""
    ])
    error_message = "geo_replication.linked_managed_redis_ids must not contain empty strings."
  }

  validation {
    condition = var.geo_replication == null || (
      var.default_database != null &&
      try(var.default_database.geo_replication_group_name, null) != null &&
      trimspace(var.default_database.geo_replication_group_name) != ""
    )
    error_message = "geo_replication requires default_database.geo_replication_group_name to be set."
  }
}

variable "monitoring" {
  description = <<-EOT
    Monitoring configuration for Managed Redis.

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
    error_message = "Azure allows a maximum of 5 diagnostic settings per Managed Redis resource."
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
      alltrue([for category in(ds.log_categories == null ? [] : ds.log_categories) : category != ""]) &&
      alltrue([for category in(ds.metric_categories == null ? [] : ds.metric_categories) : category != ""])
    ])
    error_message = "log_categories and metric_categories must not contain empty strings."
  }

  validation {
    condition = alltrue([
      for ds in var.monitoring :
      (ds.log_categories == null || length(ds.log_categories) == 0) || var.default_database != null
    ])
    error_message = "monitoring entries that configure log_categories require default_database to exist because Managed Redis connection logs target the default database resource."
  }
}

variable "tags" {
  description = <<-EOT
    Tags to apply to the Managed Redis instance.
    Provide a map of string keys and values.
  EOT
  type        = map(string)
  default     = {}
  nullable    = false
}
