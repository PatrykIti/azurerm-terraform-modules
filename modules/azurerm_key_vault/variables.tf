variable "name" {
  description = "The name of the Key Vault. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{1,22}[A-Za-z0-9])?$", var.name))
    error_message = "Key Vault name must be 3-24 characters, alphanumeric or hyphen, and cannot start/end with a hyphen."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Key Vault."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "The Azure region where the Key Vault should exist."
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "tenant_id" {
  description = "The Entra ID tenant ID used for Key Vault access policies and RBAC."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.tenant_id))
    error_message = "tenant_id must be a valid UUID."
  }
}

variable "sku_name" {
  description = "The Key Vault SKU."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be one of: standard, premium."
  }
}

variable "enabled_for_deployment" {
  description = "Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Whether Azure Disk Encryption is permitted to retrieve secrets from the Key Vault and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault."
  type        = bool
  default     = false
}

variable "rbac_authorization_enabled" {
  description = "Whether RBAC authorization is enabled for Key Vault data-plane operations."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for this Key Vault."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted."
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled for this Key Vault."
  type        = bool
  default     = true
}

variable "network_acls" {
  description = <<-EOT
    Network ACLs for the Key Vault.

    bypass: Which traffic can bypass the network rules (AzureServices or None).
    default_action: Default action when no rules match (Allow or Deny).
    ip_rules: List of IPv4 addresses or CIDR ranges.
    virtual_network_subnet_ids: List of subnet IDs to allow.
  EOT

  type = object({
    bypass                     = optional(string, "AzureServices")
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })

  default = null

  validation {
    condition     = var.network_acls == null || contains(["AzureServices", "None"], var.network_acls.bypass)
    error_message = "network_acls.bypass must be AzureServices or None."
  }

  validation {
    condition     = var.network_acls == null || contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "network_acls.default_action must be Allow or Deny."
  }

  validation {
    condition = var.network_acls == null || alltrue([
      for rule in var.network_acls.ip_rules : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}(?:/\\d{1,2})?$", rule))
    ])
    error_message = "network_acls.ip_rules entries must be IPv4 addresses or CIDR ranges."
  }
}

variable "contacts" {
  description = "Key Vault contacts for certificate notifications."
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = alltrue([for contact in var.contacts : length(trimspace(contact.email)) > 0])
    error_message = "contacts.email must not be empty."
  }
}

variable "access_policies" {
  description = <<-EOT
    Access policies applied when RBAC authorization is disabled.

    Each entry must have a unique name.
  EOT

  type = list(object({
    name                    = string
    tenant_id               = optional(string)
    object_id               = string
    application_id          = optional(string)
    certificate_permissions = optional(list(string), [])
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for policy in var.access_policies : policy.name])) == length(var.access_policies)
    error_message = "access_policies names must be unique."
  }

  validation {
    condition     = !var.rbac_authorization_enabled || length(var.access_policies) == 0
    error_message = "access_policies cannot be set when rbac_authorization_enabled is true."
  }

  validation {
    condition = alltrue([
      for policy in var.access_policies : policy.tenant_id == null || policy.tenant_id == var.tenant_id
    ])
    error_message = "access_policies.tenant_id must match tenant_id when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.access_policies : alltrue([
        for permission in policy.certificate_permissions : contains([
          "Backup",
          "Create",
          "Delete",
          "DeleteIssuers",
          "Get",
          "GetIssuers",
          "Import",
          "List",
          "ListIssuers",
          "ManageContacts",
          "ManageIssuers",
          "Purge",
          "Recover",
          "Restore",
          "SetIssuers",
          "Update"
        ], permission)
      ])
    ])
    error_message = "access_policies.certificate_permissions contains unsupported values."
  }

  validation {
    condition = alltrue([
      for policy in var.access_policies : alltrue([
        for permission in policy.key_permissions : contains([
          "Backup",
          "Create",
          "Decrypt",
          "Delete",
          "Encrypt",
          "Get",
          "Import",
          "List",
          "Purge",
          "Recover",
          "Restore",
          "Sign",
          "UnwrapKey",
          "Update",
          "Verify",
          "WrapKey",
          "Release",
          "Rotate",
          "GetRotationPolicy",
          "SetRotationPolicy"
        ], permission)
      ])
    ])
    error_message = "access_policies.key_permissions contains unsupported values."
  }

  validation {
    condition = alltrue([
      for policy in var.access_policies : alltrue([
        for permission in policy.secret_permissions : contains([
          "Backup",
          "Delete",
          "Get",
          "List",
          "Purge",
          "Recover",
          "Restore",
          "Set"
        ], permission)
      ])
    ])
    error_message = "access_policies.secret_permissions contains unsupported values."
  }

  validation {
    condition = alltrue([
      for policy in var.access_policies : alltrue([
        for permission in policy.storage_permissions : contains([
          "Backup",
          "Delete",
          "DeleteSAS",
          "Get",
          "GetSAS",
          "List",
          "ListSAS",
          "Purge",
          "Recover",
          "RegenerateKey",
          "Restore",
          "Set",
          "SetSAS",
          "Update"
        ], permission)
      ])
    ])
    error_message = "access_policies.storage_permissions contains unsupported values."
  }
}

variable "keys" {
  description = "Key Vault keys to create. Each entry must have a unique name."
  type = list(object({
    name            = string
    key_type        = string
    key_opts        = list(string)
    key_size        = optional(number)
    curve           = optional(string)
    not_before_date = optional(string)
    expiration_date = optional(string)
    tags            = optional(map(string), {})
    rotation_policy = optional(object({
      expire_after         = optional(string)
      notify_before_expiry = optional(string)
      automatic = optional(object({
        time_after_creation = optional(string)
        time_before_expiry  = optional(string)
      }))
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for key in var.keys : key.name])) == length(var.keys)
    error_message = "keys names must be unique."
  }

  validation {
    condition = alltrue([
      for key in var.keys : contains(["EC", "EC-HSM", "RSA", "RSA-HSM", "oct"], key.key_type)
    ])
    error_message = "keys.key_type must be one of: EC, EC-HSM, RSA, RSA-HSM, oct."
  }

  validation {
    condition = alltrue([
      for key in var.keys : length(key.key_opts) > 0 && alltrue([
        for opt in key.key_opts : contains(["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"], opt)
      ])
    ])
    error_message = "keys.key_opts must include only: decrypt, encrypt, sign, unwrapKey, verify, wrapKey."
  }

  validation {
    condition = alltrue([
      for key in var.keys : !contains(["RSA", "RSA-HSM"], key.key_type) || (
        key.key_size != null && contains([2048, 3072, 4096], key.key_size)
      )
    ])
    error_message = "keys.key_size must be 2048, 3072, or 4096 for RSA/RSA-HSM keys."
  }

  validation {
    condition = alltrue([
      for key in var.keys : !contains(["EC", "EC-HSM"], key.key_type) || (
        key.curve != null && contains(["P-256", "P-384", "P-521", "P-256K"], key.curve)
      )
    ])
    error_message = "keys.curve must be set to P-256, P-384, P-521, or P-256K for EC/EC-HSM keys."
  }

  validation {
    condition = alltrue([
      for key in var.keys : !(contains(["EC", "EC-HSM"], key.key_type) && key.key_size != null)
    ])
    error_message = "keys.key_size cannot be set for EC/EC-HSM keys."
  }

  validation {
    condition = alltrue([
      for key in var.keys : !(contains(["RSA", "RSA-HSM", "oct"], key.key_type) && key.curve != null)
    ])
    error_message = "keys.curve cannot be set for RSA/RSA-HSM/oct keys."
  }
}

variable "secrets" {
  description = "Key Vault secrets to create. Each entry must have a unique name."
  type = list(object({
    name             = string
    value            = optional(string)
    value_wo         = optional(string)
    value_wo_version = optional(number)
    content_type     = optional(string)
    not_before_date  = optional(string)
    expiration_date  = optional(string)
    tags             = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for secret in var.secrets : secret.name])) == length(var.secrets)
    error_message = "secrets names must be unique."
  }

  validation {
    condition = alltrue([
      for secret in var.secrets : (
        (secret.value != null ? 1 : 0) + (secret.value_wo != null ? 1 : 0)
      ) == 1
    ])
    error_message = "secrets must set exactly one of value or value_wo."
  }

  validation {
    condition = alltrue([
      for secret in var.secrets : secret.value == null || length(trimspace(secret.value)) > 0
    ])
    error_message = "secrets.value must not be empty when set."
  }

  validation {
    condition = alltrue([
      for secret in var.secrets : secret.value_wo == null || (
        length(trimspace(secret.value_wo)) > 0 && secret.value_wo_version != null
      )
    ])
    error_message = "secrets.value_wo requires value_wo_version and must not be empty."
  }
}

variable "certificates" {
  description = "Key Vault certificates to create. Each entry must have a unique name."
  type = list(object({
    name = string
    certificate = optional(object({
      contents = string
      password = optional(string)
    }))
    certificate_policy = optional(object({
      issuer_parameters = object({
        name = string
      })
      key_properties = object({
        exportable = bool
        key_type   = string
        key_size   = optional(number)
        curve      = optional(string)
        reuse_key  = bool
      })
      secret_properties = object({
        content_type = string
      })
      x509_certificate_properties = optional(object({
        subject            = string
        validity_in_months = number
        key_usage          = set(string)
        extended_key_usage = optional(list(string))
        subject_alternative_names = optional(object({
          dns_names = optional(set(string))
          emails    = optional(set(string))
          upns      = optional(set(string))
        }))
      }))
      lifetime_actions = optional(list(object({
        action_type         = string
        days_before_expiry  = optional(number)
        lifetime_percentage = optional(number)
      })), [])
    }))
    tags = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for cert in var.certificates : cert.name])) == length(var.certificates)
    error_message = "certificates names must be unique."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : (cert.certificate != null || cert.certificate_policy != null)
    ])
    error_message = "certificates require either certificate or certificate_policy."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : cert.certificate_policy == null || contains(["EC", "EC-HSM", "RSA", "RSA-HSM"], cert.certificate_policy.key_properties.key_type)
    ])
    error_message = "certificates.certificate_policy.key_properties.key_type must be EC, EC-HSM, RSA, or RSA-HSM."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : cert.certificate_policy == null || !contains(["RSA", "RSA-HSM"], cert.certificate_policy.key_properties.key_type) || (
        cert.certificate_policy.key_properties.key_size != null && contains([2048, 3072, 4096], cert.certificate_policy.key_properties.key_size)
      )
    ])
    error_message = "certificates.certificate_policy.key_properties.key_size must be 2048, 3072, or 4096 for RSA/RSA-HSM."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : cert.certificate_policy == null || !contains(["EC", "EC-HSM"], cert.certificate_policy.key_properties.key_type) || (
        cert.certificate_policy.key_properties.curve != null && contains(["P-256", "P-384", "P-521", "P-256K"], cert.certificate_policy.key_properties.curve)
      )
    ])
    error_message = "certificates.certificate_policy.key_properties.curve must be P-256, P-384, P-521, or P-256K for EC/EC-HSM."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : cert.certificate_policy == null || !(contains(["EC", "EC-HSM"], cert.certificate_policy.key_properties.key_type) && cert.certificate_policy.key_properties.key_size != null)
    ])
    error_message = "certificates.certificate_policy.key_properties.key_size cannot be set for EC/EC-HSM."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : cert.certificate_policy == null || !(contains(["RSA", "RSA-HSM"], cert.certificate_policy.key_properties.key_type) && cert.certificate_policy.key_properties.curve != null)
    ])
    error_message = "certificates.certificate_policy.key_properties.curve cannot be set for RSA/RSA-HSM."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : cert.certificate_policy == null || alltrue([
        for action in cert.certificate_policy.lifetime_actions : (
          action.days_before_expiry != null || action.lifetime_percentage != null
        )
      ])
    ])
    error_message = "certificates.certificate_policy.lifetime_actions must set days_before_expiry or lifetime_percentage."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : cert.certificate_policy == null || cert.certificate_policy.x509_certificate_properties == null || alltrue([
        for usage in cert.certificate_policy.x509_certificate_properties.key_usage : contains([
          "cRLSign",
          "dataEncipherment",
          "decipherOnly",
          "digitalSignature",
          "encipherOnly",
          "keyAgreement",
          "keyCertSign",
          "keyEncipherment",
          "nonRepudiation"
        ], usage)
      ])
    ])
    error_message = "certificates.certificate_policy.x509_certificate_properties.key_usage contains unsupported values."
  }

  validation {
    condition = alltrue([
      for cert in var.certificates : cert.certificate_policy == null || alltrue([
        for action in cert.certificate_policy.lifetime_actions : contains(["AutoRenew", "EmailContacts"], action.action_type)
      ])
    ])
    error_message = "certificates.certificate_policy.lifetime_actions.action_type must be AutoRenew or EmailContacts."
  }
}

variable "certificate_issuers" {
  description = "Certificate issuers registered in the Key Vault. Each entry must have a unique name."
  type = list(object({
    name          = string
    provider_name = string
    account_id    = optional(string)
    password      = optional(string)
    org_id        = optional(string)
    administrators = optional(list(object({
      email_address = string
      first_name    = optional(string)
      last_name     = optional(string)
      phone         = optional(string)
    })), [])
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for issuer in var.certificate_issuers : issuer.name])) == length(var.certificate_issuers)
    error_message = "certificate_issuers names must be unique."
  }
}

variable "managed_storage_accounts" {
  description = "Managed storage accounts registered in the Key Vault. Each entry must have a unique name."
  type = list(object({
    name                         = string
    storage_account_id           = string
    storage_account_key          = string
    regenerate_key_automatically = optional(bool, false)
    regeneration_period          = optional(string)
    tags                         = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for account in var.managed_storage_accounts : account.name])) == length(var.managed_storage_accounts)
    error_message = "managed_storage_accounts names must be unique."
  }

  validation {
    condition = alltrue([
      for account in var.managed_storage_accounts : length(trimspace(account.storage_account_id)) > 0
    ])
    error_message = "managed_storage_accounts.storage_account_id must not be empty."
  }

  validation {
    condition = alltrue([
      for account in var.managed_storage_accounts : length(trimspace(account.storage_account_key)) > 0
    ])
    error_message = "managed_storage_accounts.storage_account_key must not be empty."
  }

  validation {
    condition = alltrue([
      for account in var.managed_storage_accounts : !account.regenerate_key_automatically || (account.regeneration_period != null && length(trimspace(account.regeneration_period)) > 0)
    ])
    error_message = "managed_storage_accounts.regeneration_period is required when regenerate_key_automatically is true."
  }
}

variable "managed_storage_sas_definitions" {
  description = "Managed storage SAS token definitions. Each entry must have a unique name."
  type = list(object({
    name                         = string
    managed_storage_account_name = optional(string)
    managed_storage_account_id   = optional(string)
    sas_template_uri             = string
    sas_type                     = string
    validity_period              = string
    tags                         = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for definition in var.managed_storage_sas_definitions : definition.name])) == length(var.managed_storage_sas_definitions)
    error_message = "managed_storage_sas_definitions names must be unique."
  }

  validation {
    condition = alltrue([
      for definition in var.managed_storage_sas_definitions : (
        (definition.managed_storage_account_name != null ? 1 : 0) + (definition.managed_storage_account_id != null ? 1 : 0)
      ) == 1
    ])
    error_message = "managed_storage_sas_definitions must set exactly one of managed_storage_account_name or managed_storage_account_id."
  }

  validation {
    condition = alltrue([
      for definition in var.managed_storage_sas_definitions : definition.managed_storage_account_name == null || contains([
        for account in var.managed_storage_accounts : account.name
      ], definition.managed_storage_account_name)
    ])
    error_message = "managed_storage_sas_definitions.managed_storage_account_name must reference a managed_storage_accounts entry."
  }

  validation {
    condition     = alltrue([for definition in var.managed_storage_sas_definitions : contains(["account", "service"], definition.sas_type)])
    error_message = "managed_storage_sas_definitions.sas_type must be account or service."
  }

  validation {
    condition = alltrue([
      for definition in var.managed_storage_sas_definitions : length(trimspace(definition.sas_template_uri)) > 0
    ])
    error_message = "managed_storage_sas_definitions.sas_template_uri must not be empty."
  }

  validation {
    condition = alltrue([
      for definition in var.managed_storage_sas_definitions : length(trimspace(definition.validity_period)) > 0
    ])
    error_message = "managed_storage_sas_definitions.validity_period must not be empty."
  }
}

variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for the Key Vault.

    Supported categories for azurerm 4.57.0:
    - log_categories: AuditEvent, AzurePolicyEvaluationDetails
    - metric_categories: AllMetrics
    - log_category_groups: allLogs
  EOT

  type = list(object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    partner_solution_id            = optional(string)
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    log_category_groups            = optional(list(string))
  }))

  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for ds in var.diagnostic_settings : ds.name])) == length(var.diagnostic_settings)
    error_message = "diagnostic_settings names must be unique."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings : (
        ds.log_analytics_workspace_id != null ||
        ds.storage_account_id != null ||
        ds.eventhub_authorization_rule_id != null ||
        ds.partner_solution_id != null
      )
    ])
    error_message = "diagnostic_settings entries require at least one destination (log analytics, storage, eventhub, or partner solution)."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings : ds.eventhub_name == null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "diagnostic_settings.eventhub_name requires eventhub_authorization_rule_id."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings : ds.log_analytics_destination_type == null || contains(["AzureDiagnostics", "Dedicated"], ds.log_analytics_destination_type)
    ])
    error_message = "diagnostic_settings.log_analytics_destination_type must be AzureDiagnostics or Dedicated when set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings : (
        alltrue([for c in(ds.log_categories == null ? [] : ds.log_categories) : trimspace(c) != ""]) &&
        alltrue([for c in(ds.metric_categories == null ? [] : ds.metric_categories) : trimspace(c) != ""]) &&
        alltrue([for c in(ds.log_category_groups == null ? [] : ds.log_category_groups) : trimspace(c) != ""])
      )
    ])
    error_message = "diagnostic_settings category values must not contain empty strings."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings : (
        length(coalesce(ds.log_categories, [])) +
        length(coalesce(ds.metric_categories, [])) +
        length(coalesce(ds.log_category_groups, []))
      ) > 0
    ])
    error_message = "diagnostic_settings entries must define at least one category: log_categories, metric_categories, or log_category_groups."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings : alltrue([
        for category in(ds.log_categories == null ? [] : ds.log_categories) : contains(["AuditEvent", "AzurePolicyEvaluationDetails"], category)
      ])
    ])
    error_message = "diagnostic_settings.log_categories may include only: AuditEvent, AzurePolicyEvaluationDetails."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings : alltrue([
        for category in(ds.metric_categories == null ? [] : ds.metric_categories) : contains(["AllMetrics"], category)
      ])
    ])
    error_message = "diagnostic_settings.metric_categories may include only: AllMetrics."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings : alltrue([
        for group in(ds.log_category_groups == null ? [] : ds.log_category_groups) : contains(["allLogs"], group)
      ])
    ])
    error_message = "diagnostic_settings.log_category_groups may include only: allLogs."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the Key Vault and related resources."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Timeouts for Key Vault operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
