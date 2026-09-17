# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

variable "strategy" {
  description = "Secret management strategy to use. Valid values: manual, csi, eso."
  type        = string

  validation {
    condition     = contains(["manual", "csi", "eso"], var.strategy)
    error_message = "strategy must be one of: manual, csi, eso."
  }

  validation {
    condition = (
      var.strategy == "manual" && var.manual != null && var.csi == null && var.eso == null
      ) || (
      var.strategy == "csi" && var.csi != null && var.manual == null && var.eso == null
      ) || (
      var.strategy == "eso" && var.eso != null && var.manual == null && var.csi == null
    )
    error_message = "Set exactly one strategy block that matches strategy (manual/csi/eso), and keep the others null."
  }
}

variable "namespace" {
  description = "Kubernetes namespace for created objects."
  type        = string

  validation {
    condition     = length(var.namespace) > 0 && length(var.namespace) <= 253
    error_message = "namespace must be between 1 and 253 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    error_message = "namespace must be a valid DNS-1123 label (lowercase letters, numbers, hyphens)."
  }
}

variable "name" {
  description = "Base name for the created Kubernetes objects (Secret / SecretProviderClass / ExternalSecret)."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 253
    error_message = "name must be between 1 and 253 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must be a valid DNS-1123 label (lowercase letters, numbers, hyphens)."
  }
}

variable "labels" {
  description = "Labels to apply to all Kubernetes objects created by the module."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to all Kubernetes objects created by the module."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Manual Strategy (KV -> TF -> K8s Secret)
# -----------------------------------------------------------------------------

variable "manual" {
  description = <<-EOT
    Manual strategy configuration (caller-provided values -> Kubernetes Secret).

    kubernetes_secret_type: Kubernetes Secret type (default: Opaque).
    secrets: List of mappings from provided values to Kubernetes Secret keys.
  EOT

  type = object({
    kubernetes_secret_type = optional(string, "Opaque")
    secrets = list(object({
      name                  = string
      kubernetes_secret_key = string
      value                 = string
    }))
  })

  default = null

  validation {
    condition     = var.manual == null || length(var.manual.secrets) > 0
    error_message = "manual.secrets must contain at least one entry when manual is set."
  }

  validation {
    condition = var.manual == null || length(distinct([
      for secret in var.manual.secrets : secret.name
    ])) == length(var.manual.secrets)
    error_message = "manual.secrets[*].name must be unique."
  }

  validation {
    condition = var.manual == null || length(distinct([
      for secret in var.manual.secrets : secret.kubernetes_secret_key
    ])) == length(var.manual.secrets)
    error_message = "manual.secrets[*].kubernetes_secret_key must be unique."
  }
}

# -----------------------------------------------------------------------------
# CSI Strategy (SecretProviderClass)
# -----------------------------------------------------------------------------

variable "csi" {
  description = <<-EOT
    CSI strategy configuration (SecretProviderClass).

    tenant_id: Azure Tenant ID.
    key_vault_name: Key Vault name.
    user_assigned_identity_client_id: Optional client ID for user-assigned identity (CSI).
    sync_to_kubernetes_secret: Whether to sync to a Kubernetes Secret.
  EOT

  type = object({
    tenant_id                        = string
    key_vault_name                   = string
    user_assigned_identity_client_id = optional(string)
    sync_to_kubernetes_secret        = optional(bool, false)
    kubernetes_secret_name           = optional(string)
    kubernetes_secret_type           = optional(string, "Opaque")
    objects = list(object({
      name           = string
      object_name    = string
      object_type    = string
      object_version = optional(string)
      secret_key     = optional(string)
    }))
  })

  default = null

  validation {
    condition     = var.csi == null || length(var.csi.objects) > 0
    error_message = "csi.objects must contain at least one entry when csi is set."
  }

  validation {
    condition = var.csi == null || length(distinct([
      for object in var.csi.objects : object.name
    ])) == length(var.csi.objects)
    error_message = "csi.objects[*].name must be unique."
  }

  validation {
    condition = var.csi == null || alltrue([
      for object in var.csi.objects : contains(["secret", "key", "cert"], object.object_type)
    ])
    error_message = "csi.objects[*].object_type must be one of: secret, key, cert."
  }

  validation {
    condition = var.csi == null || (
      var.csi.sync_to_kubernetes_secret == false || (
        var.csi.kubernetes_secret_name != null &&
        alltrue([for object in var.csi.objects : try(object.secret_key, null) != null])
      )
    )
    error_message = "When csi.sync_to_kubernetes_secret is true, kubernetes_secret_name and objects[*].secret_key are required."
  }
}

# -----------------------------------------------------------------------------
# ESO Strategy (SecretStore + ExternalSecret)
# -----------------------------------------------------------------------------

variable "eso" {
  description = <<-EOT
    External Secrets Operator strategy configuration.

    secret_store: SecretStore/ClusterSecretStore configuration.
    external_secrets: List of ExternalSecret definitions.
  EOT

  type = object({
    secret_store = object({
      kind           = string
      name           = string
      tenant_id      = string
      key_vault_url  = optional(string)
      key_vault_name = optional(string)
      auth = object({
        type = string
        workload_identity = optional(object({
          service_account_name      = string
          service_account_namespace = optional(string)
          client_id                 = optional(string)
        }))
        service_principal = optional(object({
          client_id     = string
          client_secret = string
          tenant_id     = string
          secret_keys = optional(object({
            client_id     = optional(string, "clientId")
            client_secret = optional(string, "clientSecret")
          }))
        }))
        managed_identity = optional(object({
          client_id   = optional(string)
          resource_id = optional(string)
        }))
      })
    })
    external_secrets = list(object({
      name             = string
      refresh_interval = optional(string)
      remote_ref = object({
        name    = string
        version = optional(string)
      })
      target = object({
        secret_name = string
        secret_key  = string
      })
    }))
  })

  default   = null
  sensitive = true

  validation {
    condition     = var.eso == null || contains(["SecretStore", "ClusterSecretStore"], var.eso.secret_store.kind)
    error_message = "eso.secret_store.kind must be SecretStore or ClusterSecretStore."
  }

  validation {
    condition = var.eso == null || (
      (var.eso.secret_store.key_vault_url != null) != (var.eso.secret_store.key_vault_name != null)
    )
    error_message = "Set exactly one of eso.secret_store.key_vault_url or eso.secret_store.key_vault_name."
  }

  validation {
    condition     = var.eso == null || contains(["workload_identity", "service_principal", "managed_identity"], var.eso.secret_store.auth.type)
    error_message = "eso.secret_store.auth.type must be workload_identity, service_principal, or managed_identity."
  }

  validation {
    condition = var.eso == null || (
      var.eso.secret_store.auth.type == "workload_identity" &&
      var.eso.secret_store.auth.workload_identity != null &&
      var.eso.secret_store.auth.service_principal == null &&
      var.eso.secret_store.auth.managed_identity == null
      ) || (
      var.eso.secret_store.auth.type == "service_principal" &&
      var.eso.secret_store.auth.service_principal != null &&
      var.eso.secret_store.auth.workload_identity == null &&
      var.eso.secret_store.auth.managed_identity == null
      ) || (
      var.eso.secret_store.auth.type == "managed_identity" &&
      var.eso.secret_store.auth.managed_identity != null &&
      var.eso.secret_store.auth.workload_identity == null &&
      var.eso.secret_store.auth.service_principal == null
    )
    error_message = "Provide exactly one auth block that matches eso.secret_store.auth.type."
  }

  validation {
    condition = var.eso == null || (
      var.eso.secret_store.auth.type != "managed_identity" || (
        try(var.eso.secret_store.auth.managed_identity.client_id, null) != null ||
        try(var.eso.secret_store.auth.managed_identity.resource_id, null) != null
      )
    )
    error_message = "managed_identity requires client_id or resource_id."
  }

  validation {
    condition = var.eso == null || (
      var.eso.secret_store.auth.type != "service_principal" || (
        trim(try(var.eso.secret_store.auth.service_principal.secret_keys.client_id, "clientId")) != "" &&
        trim(try(var.eso.secret_store.auth.service_principal.secret_keys.client_secret, "clientSecret")) != "" &&
        try(var.eso.secret_store.auth.service_principal.secret_keys.client_id, "clientId") != try(var.eso.secret_store.auth.service_principal.secret_keys.client_secret, "clientSecret")
      )
    )
    error_message = "service_principal.secret_keys must define non-empty, distinct key names."
  }

  validation {
    condition     = var.eso == null || length(var.eso.external_secrets) > 0
    error_message = "eso.external_secrets must contain at least one entry when eso is set."
  }

  validation {
    condition = var.eso == null || length(distinct([
      for external_secret in var.eso.external_secrets : external_secret.name
    ])) == length(var.eso.external_secrets)
    error_message = "eso.external_secrets[*].name must be unique."
  }
}
