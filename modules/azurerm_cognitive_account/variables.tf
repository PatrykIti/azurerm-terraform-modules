# Core configuration
variable "name" {
  description = "The name of the Cognitive Account. Must start with an alphanumeric character and contain only alphanumerics, periods, dashes, or underscores."
  type        = string

  validation {
    condition     = can(regex("^([a-zA-Z0-9][a-zA-Z0-9_.-]{1,63})$", var.name))
    error_message = "name must start with an alphanumeric character, be 2-64 characters long, and contain only alphanumerics, periods, dashes, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Cognitive Account."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "The Azure region where the Cognitive Account should exist."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location must not be empty."
  }
}

variable "kind" {
  description = "The Cognitive Account kind. Supported values: OpenAI, TextAnalytics (Language), Speech, SpeechServices. The value Language is normalized to TextAnalytics."
  type        = string

  validation {
    condition     = contains(["OpenAI", "TextAnalytics", "Speech", "SpeechServices", "Language"], var.kind)
    error_message = "kind must be one of: OpenAI, TextAnalytics, Speech, SpeechServices, or Language (normalized to TextAnalytics)."
  }
}

variable "sku_name" {
  description = "The SKU name for the Cognitive Account. Allowed values are defined by the AzureRM provider."
  type        = string

  validation {
    condition = contains([
      "C2", "C3", "C4", "D3", "DC0", "E0", "F0", "F1", "P0", "P1", "P2", "S", "S0", "S1", "S2", "S3", "S4", "S5", "S6"
    ], var.sku_name)
    error_message = "sku_name must be one of: C2, C3, C4, D3, DC0, E0, F0, F1, P0, P1, P2, S, S0, S1, S2, S3, S4, S5, S6."
  }
}

# Network + authentication
variable "custom_subdomain_name" {
  description = "The custom subdomain name used for Entra ID token-based authentication. Required when network_acls is set."
  type        = string
  default     = null

  validation {
    condition     = var.custom_subdomain_name == null || trimspace(var.custom_subdomain_name) != ""
    error_message = "custom_subdomain_name must not be an empty string when set."
  }
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Cognitive Account."
  type        = bool
  default     = false
}

variable "local_auth_enabled" {
  description = "Whether local authentication is enabled for the Cognitive Account."
  type        = bool
  default     = false
}

variable "outbound_network_access_restricted" {
  description = "Whether outbound network access is restricted for the Cognitive Account."
  type        = bool
  default     = false
}

variable "fqdns" {
  description = "List of FQDNs allowed for the Cognitive Account."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for fqdn in var.fqdns : trimspace(fqdn) != ""])
    error_message = "fqdns must not contain empty strings."
  }
}

variable "network_acls" {
  description = "Network ACLs configuration for the Cognitive Account."
  type = object({
    default_action = string
    bypass         = optional(string)
    ip_rules       = optional(list(string), [])
    virtual_network_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })), [])
  })
  default = null

  validation {
    condition     = var.network_acls == null || contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "network_acls.default_action must be Allow or Deny."
  }

  validation {
    condition     = var.network_acls == null || var.network_acls.bypass == null || contains(["None", "AzureServices"], var.network_acls.bypass)
    error_message = "network_acls.bypass must be None or AzureServices when set."
  }

  validation {
    condition = var.network_acls == null || alltrue([
      for ip in coalesce(var.network_acls.ip_rules, []) : trimspace(ip) != ""
    ])
    error_message = "network_acls.ip_rules must not contain empty strings."
  }

  validation {
    condition = var.network_acls == null || alltrue([
      for rule in coalesce(var.network_acls.virtual_network_rules, []) : trimspace(rule.subnet_id) != ""
    ])
    error_message = "network_acls.virtual_network_rules subnet_id must not be empty."
  }

  validation {
    condition = var.network_acls == null || (
      var.custom_subdomain_name != null && var.custom_subdomain_name != ""
    )
    error_message = "custom_subdomain_name is required when network_acls is set."
  }

  validation {
    condition = var.network_acls == null || var.network_acls.bypass == null || contains(
      ["OpenAI", "TextAnalytics", "Language"],
      var.kind
    )
    error_message = "network_acls.bypass is only supported for kind OpenAI or TextAnalytics (Language)."
  }
}

# Identity + encryption
variable "identity" {
  description = "Managed identity configuration for the Cognitive Account."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.identity == null || contains(
      ["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"],
      var.identity.type
    )
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }

  validation {
    condition = var.identity == null || (
      !strcontains(lower(var.identity.type), "userassigned") ||
      length(var.identity.identity_ids) > 0
    )
    error_message = "identity.identity_ids is required when identity.type includes UserAssigned."
  }

  validation {
    condition = var.identity == null || alltrue([
      for identity_id in var.identity.identity_ids : trimspace(identity_id) != ""
    ])
    error_message = "identity.identity_ids must not contain empty values."
  }

  validation {
    condition     = var.identity == null || length(distinct(var.identity.identity_ids)) == length(var.identity.identity_ids)
    error_message = "identity.identity_ids must contain unique values."
  }
}

variable "customer_managed_key" {
  description = "Customer-managed key configuration for the Cognitive Account."
  type = object({
    key_vault_key_id      = string
    identity_client_id    = optional(string)
    use_separate_resource = optional(bool, false)
  })
  default = null

  validation {
    condition     = var.customer_managed_key == null || var.customer_managed_key.key_vault_key_id != ""
    error_message = "customer_managed_key.key_vault_key_id must not be empty when set."
  }

  validation {
    condition = var.customer_managed_key == null || (
      var.customer_managed_key.identity_client_id == null ||
      trimspace(var.customer_managed_key.identity_client_id) != ""
    )
    error_message = "customer_managed_key.identity_client_id must not be an empty string when set."
  }

  validation {
    condition = var.customer_managed_key == null || (
      var.identity != null &&
      strcontains(lower(var.identity.type), "userassigned")
    )
    error_message = "customer_managed_key requires identity.type to include UserAssigned."
  }
}

# Storage
variable "storage" {
  description = "Optional storage configuration for Cognitive Account user-owned storage."
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = alltrue([for entry in var.storage : trimspace(entry.storage_account_id) != ""])
    error_message = "storage.storage_account_id must not be empty."
  }

  validation {
    condition     = var.kind != "OpenAI" || length(var.storage) == 0
    error_message = "storage is not supported for kind OpenAI."
  }

  validation {
    condition = alltrue([
      for entry in var.storage :
      entry.identity_client_id == null || trimspace(entry.identity_client_id) != ""
    ])
    error_message = "storage.identity_client_id must not be an empty string when set."
  }
}

# OpenAI sub-resources
variable "deployments" {
  description = "OpenAI deployments to create when kind is OpenAI."
  type = list(object({
    name = string
    model = object({
      format  = string
      name    = string
      version = optional(string)
    })
    sku = object({
      name     = string
      tier     = optional(string)
      size     = optional(string)
      family   = optional(string)
      capacity = optional(number)
    })
    dynamic_throttling_enabled = optional(bool)
    rai_policy_name            = optional(string)
    version_upgrade_option     = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = var.kind == "OpenAI" || length(var.deployments) == 0
    error_message = "deployments are only supported when kind is OpenAI."
  }

  validation {
    condition     = length(distinct([for deployment in var.deployments : deployment.name])) == length(var.deployments)
    error_message = "deployments names must be unique."
  }

  validation {
    condition = alltrue([
      for deployment in var.deployments :
      trimspace(deployment.name) != "" &&
      trimspace(deployment.model.format) != "" &&
      trimspace(deployment.model.name) != "" &&
      trimspace(deployment.sku.name) != ""
    ])
    error_message = "deployments require non-empty name, model.format, model.name, and sku.name."
  }

  validation {
    condition = alltrue([
      for deployment in var.deployments :
      deployment.version_upgrade_option == null || contains([
        "OnceNewDefaultVersionAvailable",
        "OnceCurrentVersionExpired",
        "NoAutoUpgrade"
      ], deployment.version_upgrade_option)
    ])
    error_message = "deployments.version_upgrade_option must be OnceNewDefaultVersionAvailable, OnceCurrentVersionExpired, or NoAutoUpgrade."
  }

  validation {
    condition = alltrue([
      for deployment in var.deployments :
      contains([
        "Standard",
        "DataZoneBatch",
        "DataZoneStandard",
        "DataZoneProvisionedManaged",
        "GlobalBatch",
        "GlobalProvisionedManaged",
        "GlobalStandard",
        "ProvisionedManaged"
      ], deployment.sku.name)
    ])
    error_message = "deployments.sku.name must be one of: Standard, DataZoneBatch, DataZoneStandard, DataZoneProvisionedManaged, GlobalBatch, GlobalProvisionedManaged, GlobalStandard, ProvisionedManaged."
  }

  validation {
    condition = alltrue([
      for deployment in var.deployments :
      deployment.sku.capacity == null || deployment.sku.capacity > 0
    ])
    error_message = "deployments.sku.capacity must be greater than 0 when set."
  }

  validation {
    condition = alltrue([
      for deployment in var.deployments :
      deployment.rai_policy_name == null || trimspace(deployment.rai_policy_name) != ""
    ])
    error_message = "deployments.rai_policy_name must not be an empty string when set."
  }
}

variable "rai_policies" {
  description = "OpenAI RAI policies to create when kind is OpenAI."
  type = list(object({
    name             = string
    base_policy_name = string
    mode             = optional(string)
    content_filters = list(object({
      name               = string
      filter_enabled     = bool
      block_enabled      = bool
      severity_threshold = string
      source             = string
    }))
    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false

  validation {
    condition     = var.kind == "OpenAI" || length(var.rai_policies) == 0
    error_message = "rai_policies are only supported when kind is OpenAI."
  }

  validation {
    condition     = length(distinct([for policy in var.rai_policies : policy.name])) == length(var.rai_policies)
    error_message = "rai_policies names must be unique."
  }

  validation {
    condition = alltrue([
      for policy in var.rai_policies :
      policy.name != "" && policy.base_policy_name != "" && length(policy.content_filters) > 0
    ])
    error_message = "rai_policies require non-empty name, base_policy_name, and at least one content_filters entry."
  }

  validation {
    condition = alltrue([
      for policy in var.rai_policies :
      policy.mode == null || contains(["Default", "Deferred", "Blocking", "Asynchronous_filter"], policy.mode)
    ])
    error_message = "rai_policies.mode must be Default, Deferred, Blocking, or Asynchronous_filter when set."
  }

  validation {
    condition = alltrue([
      for policy in var.rai_policies :
      alltrue([
        for filter in policy.content_filters :
        filter.name != "" &&
        contains(["Low", "Medium", "High"], filter.severity_threshold) &&
        contains(["Prompt", "Completion"], filter.source)
      ])
    ])
    error_message = "rai_policies.content_filters require name, severity_threshold (Low/Medium/High), and source (Prompt/Completion)."
  }
}

variable "rai_blocklists" {
  description = "OpenAI RAI blocklists to create when kind is OpenAI."
  type = list(object({
    name        = string
    description = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = var.kind == "OpenAI" || length(var.rai_blocklists) == 0
    error_message = "rai_blocklists are only supported when kind is OpenAI."
  }

  validation {
    condition     = length(distinct([for blocklist in var.rai_blocklists : blocklist.name])) == length(var.rai_blocklists)
    error_message = "rai_blocklists names must be unique."
  }

  validation {
    condition     = alltrue([for blocklist in var.rai_blocklists : blocklist.name != ""])
    error_message = "rai_blocklists.name must not be empty."
  }

  validation {
    condition = alltrue([
      for blocklist in var.rai_blocklists :
      blocklist.description == null || trimspace(blocklist.description) != ""
    ])
    error_message = "rai_blocklists.description must not be an empty string when set."
  }
}

# Diagnostics
variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings configuration for the Cognitive Account.

    Supported categories for azurerm 4.57.0:
    - log_categories: AuditEvent
    - log_category_groups: allLogs
    - metric_categories: AllMetrics
  EOT
  type = list(object({
    name                           = string
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    log_category_groups            = optional(list(string))
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
    error_message = "Azure allows a maximum of 5 diagnostic settings per Cognitive Account."
  }

  validation {
    condition     = length(distinct([for ds in var.diagnostic_settings : ds.name])) == length(var.diagnostic_settings)
    error_message = "Each diagnostic_settings entry must have a unique name."
  }

  validation {
    condition     = alltrue([for ds in var.diagnostic_settings : trimspace(ds.name) != ""])
    error_message = "Each diagnostic_settings entry name must not be empty."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      length(compact([
        ds.log_analytics_workspace_id == null ? null : trimspace(ds.log_analytics_workspace_id),
        ds.storage_account_id == null ? null : trimspace(ds.storage_account_id),
        ds.eventhub_authorization_rule_id == null ? null : trimspace(ds.eventhub_authorization_rule_id)
      ])) > 0
    ])
    error_message = "Each diagnostic_settings entry must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.eventhub_authorization_rule_id == null ||
      trimspace(ds.eventhub_authorization_rule_id) == "" ||
      (ds.eventhub_name != null && trimspace(ds.eventhub_name) != "")
    ])
    error_message = "eventhub_name is required when eventhub_authorization_rule_id is set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_workspace_id == null || trimspace(ds.log_analytics_workspace_id) != ""
    ])
    error_message = "diagnostic_settings.log_analytics_workspace_id must not be an empty string when set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.storage_account_id == null || trimspace(ds.storage_account_id) != ""
    ])
    error_message = "diagnostic_settings.storage_account_id must not be an empty string when set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.eventhub_authorization_rule_id == null || trimspace(ds.eventhub_authorization_rule_id) != ""
    ])
    error_message = "diagnostic_settings.eventhub_authorization_rule_id must not be an empty string when set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.eventhub_name == null || trimspace(ds.eventhub_name) != ""
    ])
    error_message = "diagnostic_settings.eventhub_name must not be an empty string when set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_destination_type == null || contains(["Dedicated", "AzureDiagnostics"], ds.log_analytics_destination_type)
    ])
    error_message = "log_analytics_destination_type must be Dedicated or AzureDiagnostics."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_destination_type == null || (
        ds.log_analytics_workspace_id != null &&
        trimspace(ds.log_analytics_workspace_id) != ""
      )
    ])
    error_message = "log_analytics_destination_type requires log_analytics_workspace_id."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      alltrue([for c in(ds.log_categories == null ? [] : ds.log_categories) : trimspace(c) != ""]) &&
      alltrue([for c in(ds.metric_categories == null ? [] : ds.metric_categories) : trimspace(c) != ""]) &&
      alltrue([for c in(ds.log_category_groups == null ? [] : ds.log_category_groups) : trimspace(c) != ""])
    ])
    error_message = "diagnostic_settings categories must not contain empty strings."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      length(coalesce(ds.log_categories, [])) + length(coalesce(ds.metric_categories, [])) + length(coalesce(ds.log_category_groups, [])) > 0
    ])
    error_message = "Each diagnostic_settings entry must define at least one category: log_categories, log_category_groups, or metric_categories."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      alltrue([for c in(ds.log_categories == null ? [] : ds.log_categories) : contains(["AuditEvent"], c)])
    ])
    error_message = "diagnostic_settings.log_categories may include only: AuditEvent."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      alltrue([for c in(ds.log_category_groups == null ? [] : ds.log_category_groups) : contains(["allLogs"], c)])
    ])
    error_message = "diagnostic_settings.log_category_groups may include only: allLogs."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      alltrue([for c in(ds.metric_categories == null ? [] : ds.metric_categories) : contains(["AllMetrics"], c)])
    ])
    error_message = "diagnostic_settings.metric_categories may include only: AllMetrics."
  }
}

# Timeouts
variable "timeouts" {
  description = "Optional timeouts configuration for the Cognitive Account."
  type = object({
    create = optional(string)
    update = optional(string)
    read   = optional(string)
    delete = optional(string)
  })
  default  = {}
  nullable = false
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the Cognitive Account."
  type        = map(string)
  default     = {}
}
