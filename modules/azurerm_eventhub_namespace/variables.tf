variable "name" {
  description = "The name of the Event Hub Namespace."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][-a-zA-Z0-9]{4,48}[a-zA-Z0-9]$", var.name))
    error_message = "The namespace name can contain only letters, numbers and hyphens. The namespace must start with a letter, and it must end with a letter or number and be between 6 and 50 characters long."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Event Hub Namespace."
  type        = string
}

variable "location" {
  description = "The Azure region where the Event Hub Namespace should exist."
  type        = string
}

variable "sku" {
  description = "Defines which tier to use. Valid options are Basic, Standard, and Premium."
  type        = string

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "capacity" {
  description = "Specifies the Capacity / Throughput Units for a Standard SKU namespace. Defaults to 1."
  type        = number
  default     = 1
  nullable    = true

  validation {
    condition     = var.capacity == null || (var.capacity >= 1 && var.capacity <= 40 && floor(var.capacity) == var.capacity)
    error_message = "capacity must be an integer between 1 and 40."
  }
}

variable "auto_inflate_enabled" {
  description = "Is Auto Inflate enabled for the Event Hub Namespace?"
  type        = bool
  default     = false
}

variable "maximum_throughput_units" {
  description = "Specifies the maximum number of throughput units when Auto Inflate is enabled. Valid values range from 1 to 40."
  type        = number
  default     = null

  validation {
    condition     = var.maximum_throughput_units == null || (var.maximum_throughput_units >= 1 && var.maximum_throughput_units <= 40 && floor(var.maximum_throughput_units) == var.maximum_throughput_units)
    error_message = "maximum_throughput_units must be an integer between 1 and 40."
  }
}

variable "dedicated_cluster_id" {
  description = "Specifies the ID of the Event Hub Dedicated Cluster where this Namespace should be created."
  type        = string
  default     = null

  validation {
    condition     = var.dedicated_cluster_id == null || can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.EventHub/clusters/[^/]+$", var.dedicated_cluster_id))
    error_message = "dedicated_cluster_id must be a valid Event Hub Cluster resource ID."
  }
}

variable "public_network_access_enabled" {
  description = "Is public network access enabled for the Event Hub Namespace?"
  type        = bool
  default     = true
}

variable "local_authentication_enabled" {
  description = "Is SAS authentication enabled for the Event Hub Namespace?"
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "The minimum supported TLS version for this Event Hub Namespace. In azurerm 4.57.0 only 1.2 is supported."
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.2 for azurerm 4.57.0."
  }
}

variable "identity" {
  description = "Managed identity configuration for the Event Hub Namespace."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition     = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }

  validation {
    condition     = var.identity == null || !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) || length(try(var.identity.identity_ids, [])) > 0
    error_message = "identity.identity_ids is required when identity.type includes UserAssigned."
  }
}

variable "network_rule_set" {
  description = "Network rule set configuration for the Event Hub Namespace."
  type = object({
    default_action                 = string
    public_network_access_enabled  = optional(bool)
    trusted_service_access_enabled = optional(bool)
    ip_rules = optional(list(object({
      ip_mask = string
      action  = optional(string, "Allow")
    })), [])
    vnet_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool)
    })), [])
  })
  default = null

  validation {
    condition     = var.network_rule_set == null || contains(["Allow", "Deny"], var.network_rule_set.default_action)
    error_message = "network_rule_set.default_action must be Allow or Deny."
  }

  validation {
    condition = var.network_rule_set == null || alltrue([
      for rule in coalesce(var.network_rule_set.ip_rules, []) :
      rule.ip_mask != "" && contains(["Allow"], rule.action)
    ])
    error_message = "network_rule_set.ip_rules entries must have a non-empty ip_mask and action set to Allow."
  }

  validation {
    condition = var.network_rule_set == null || alltrue([
      for rule in coalesce(var.network_rule_set.vnet_rules, []) :
      can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", rule.subnet_id))
    ])
    error_message = "network_rule_set.vnet_rules subnet_id must be a valid subnet resource ID."
  }
}

variable "namespace_authorization_rules" {
  description = "Authorization rules for the Event Hub Namespace."
  type = list(object({
    name   = string
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for rule in var.namespace_authorization_rules : rule.name])) == length(var.namespace_authorization_rules)
    error_message = "Each namespace_authorization_rules entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for rule in var.namespace_authorization_rules :
      can(regex("^[a-zA-Z0-9]([-._a-zA-Z0-9]{0,58}[a-zA-Z0-9])?$", rule.name))
    ])
    error_message = "Authorization rule names must be 1-60 chars, start/end with alphanumeric, and contain only letters, numbers, periods, hyphens, or underscores."
  }

  validation {
    condition = alltrue([
      for rule in var.namespace_authorization_rules :
      coalesce(rule.listen, false) || coalesce(rule.send, false) || coalesce(rule.manage, false)
    ])
    error_message = "Each authorization rule must enable at least one permission (listen, send, manage)."
  }

  validation {
    condition = alltrue([
      for rule in var.namespace_authorization_rules :
      !coalesce(rule.manage, false) || (coalesce(rule.listen, false) && coalesce(rule.send, false))
    ])
    error_message = "When manage is true, listen and send must also be true."
  }
}

variable "schema_groups" {
  description = "Schema registry groups for the Event Hub Namespace."
  type = list(object({
    name                 = string
    schema_type          = string
    schema_compatibility = string
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for group in var.schema_groups : group.name])) == length(var.schema_groups)
    error_message = "Each schema_groups entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for group in var.schema_groups :
      group.name != "" && group.schema_type != "" && group.schema_compatibility != ""
    ])
    error_message = "schema_groups entries must have non-empty name, schema_type, and schema_compatibility."
  }
}

variable "disaster_recovery_config" {
  description = "Optional disaster recovery configuration for the Event Hub Namespace."
  type = object({
    name                 = string
    partner_namespace_id = string
  })
  default = null

  validation {
    condition     = var.disaster_recovery_config == null || var.disaster_recovery_config.name != ""
    error_message = "disaster_recovery_config.name must not be empty."
  }

  validation {
    condition     = var.disaster_recovery_config == null || can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.EventHub/namespaces/[^/]+$", var.disaster_recovery_config.partner_namespace_id))
    error_message = "disaster_recovery_config.partner_namespace_id must be a valid Event Hub Namespace resource ID."
  }
}

variable "customer_managed_key" {
  description = "Customer-managed key configuration for the Event Hub Namespace."
  type = object({
    key_vault_key_ids                 = list(string)
    user_assigned_identity_id         = optional(string)
    infrastructure_encryption_enabled = optional(bool)
  })
  default = null

  validation {
    condition = var.customer_managed_key == null || (
      length(var.customer_managed_key.key_vault_key_ids) > 0 &&
      alltrue([for id in var.customer_managed_key.key_vault_key_ids : id != ""])
    )
    error_message = "customer_managed_key.key_vault_key_ids must contain at least one non-empty Key Vault key ID."
  }

  validation {
    condition = var.customer_managed_key == null || alltrue([
      for id in var.customer_managed_key.key_vault_key_ids :
      can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.KeyVault/vaults/[^/]+/keys/[^/]+(/[^/]+)?$", id))
    ])
    error_message = "customer_managed_key.key_vault_key_ids must be valid Key Vault key IDs."
  }

  validation {
    condition     = var.customer_managed_key == null || var.customer_managed_key.user_assigned_identity_id == null || var.customer_managed_key.user_assigned_identity_id != ""
    error_message = "customer_managed_key.user_assigned_identity_id must not be empty when set."
  }

  validation {
    condition     = var.customer_managed_key == null || var.customer_managed_key.user_assigned_identity_id == null || can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/[^/]+$", var.customer_managed_key.user_assigned_identity_id))
    error_message = "customer_managed_key.user_assigned_identity_id must be a valid user-assigned identity resource ID."
  }
}

variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for the Event Hub Namespace.

    Provide either log_categories/metric_categories or areas to select categories.
    If neither is provided, areas defaults to ["all"].
  EOT

  type = list(object({
    name                           = string
    areas                          = optional(list(string))
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
    error_message = "Azure allows a maximum of 5 diagnostic settings per Event Hub Namespace."
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
      alltrue([for area in coalesce(ds.areas, []) : contains(["all", "logs", "metrics", "archive", "operational", "autoscale", "kafka"], area)])
    ])
    error_message = "areas may only include: all, logs, metrics, archive, operational, autoscale, kafka."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      alltrue([for c in(ds.log_categories == null ? [] : ds.log_categories) : c != ""]) &&
      alltrue([for c in(ds.metric_categories == null ? [] : ds.metric_categories) : c != ""]) &&
      alltrue([for c in(ds.areas == null ? [] : ds.areas) : c != ""])
    ])
    error_message = "log_categories, metric_categories, and areas must not contain empty strings."
  }
}

variable "timeouts" {
  description = "Custom timeouts for the Event Hub Namespace resource."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
