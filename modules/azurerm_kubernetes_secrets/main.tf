# AKS Secrets Module

locals {
  is_manual = var.strategy == "manual"
  is_csi    = var.strategy == "csi"
  is_eso    = var.strategy == "eso"

  common_metadata = merge(
    {},
    length(var.labels) > 0 ? { labels = var.labels } : {},
    length(var.annotations) > 0 ? { annotations = var.annotations } : {}
  )

  manual_secrets = local.is_manual ? { for secret in var.manual.secrets : secret.name => secret } : {}

  csi_objects_yaml = local.is_csi ? yamlencode({
    array = [
      for object in var.csi.objects : merge(
        {
          objectName = object.object_name
          objectType = object.object_type
        },
        try(object.object_version, null) != null ? { objectVersion = object.object_version } : {}
      )
    ]
  }) : null

  eso_store                    = local.is_eso ? var.eso.secret_store : null
  eso_vault_url                = local.is_eso ? coalesce(var.eso.secret_store.key_vault_url, "https://${var.eso.secret_store.key_vault_name}.vault.azure.net") : null
  eso_auth_type                = local.is_eso ? var.eso.secret_store.auth.type : null
  eso_auth_type_map            = { workload_identity = "WorkloadIdentity", service_principal = "ServicePrincipal", managed_identity = "ManagedIdentity" }
  eso_service_principal_secret = local.is_eso && local.eso_auth_type == "service_principal" ? "${var.name}-eso-sp" : null
  eso_service_principal_keys = local.is_eso && local.eso_auth_type == "service_principal" ? {
    client_id     = try(var.eso.secret_store.auth.service_principal.secret_keys.client_id, "clientId")
    client_secret = try(var.eso.secret_store.auth.service_principal.secret_keys.client_secret, "clientSecret")
  } : null
  eso_workload_identity_client_id = local.is_eso && local.eso_auth_type == "workload_identity" ? try(var.eso.secret_store.auth.workload_identity.client_id, null) : null
  eso_managed_identity_id = local.is_eso && local.eso_auth_type == "managed_identity" ? coalesce(
    try(var.eso.secret_store.auth.managed_identity.client_id, null),
    try(var.eso.secret_store.auth.managed_identity.resource_id, null)
  ) : null
  eso_service_account_namespace = local.is_eso && local.eso_auth_type == "workload_identity" && local.eso_store.kind == "ClusterSecretStore" ? coalesce(
    try(var.eso.secret_store.auth.workload_identity.service_account_namespace, null),
    var.namespace
  ) : null

  eso_secret_store_for_each = local.is_eso ? {
    "store" = {
      kind           = var.eso.secret_store.kind
      name           = var.eso.secret_store.name
      tenant_id      = var.eso.secret_store.tenant_id
      key_vault_url  = try(var.eso.secret_store.key_vault_url, null)
      key_vault_name = try(var.eso.secret_store.key_vault_name, null)
      auth = {
        type              = var.eso.secret_store.auth.type
        workload_identity = try(var.eso.secret_store.auth.workload_identity, null)
        managed_identity  = try(var.eso.secret_store.auth.managed_identity, null)
      }
    }
  } : {}

  eso_external_secrets = local.is_eso ? nonsensitive({
    for external_secret in var.eso.external_secrets : external_secret.name => external_secret
  }) : {}
}

# -----------------------------------------------------------------------------
# Manual Strategy (KV -> TF -> K8s Secret)
# -----------------------------------------------------------------------------

data "azurerm_key_vault_secret" "manual" {
  for_each = local.manual_secrets

  name         = each.value.key_vault_secret_name
  key_vault_id = try(var.manual.key_vault_id, null)
  version      = try(each.value.key_vault_secret_version, null)
}

resource "kubernetes_secret_v1" "manual" {
  count = local.is_manual ? 1 : 0

  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }

  type = local.is_manual ? try(var.manual.kubernetes_secret_type, "Opaque") : "Opaque"

  data = local.is_manual ? {
    for key, secret in local.manual_secrets :
    secret.kubernetes_secret_key => data.azurerm_key_vault_secret.manual[key].value
  } : {}
}

# -----------------------------------------------------------------------------
# CSI Strategy (SecretProviderClass)
# -----------------------------------------------------------------------------

resource "kubernetes_manifest" "secret_provider_class" {
  for_each = local.is_csi ? { "csi" = var.csi } : {}

  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = merge(
      {
        name      = var.name
        namespace = var.namespace
      },
      local.common_metadata
    )
    spec = merge(
      {
        provider = "azure"
        parameters = merge(
          {
            usePodIdentity       = "false"
            useVMManagedIdentity = "true"
            keyvaultName         = each.value.key_vault_name
            tenantId             = each.value.tenant_id
            objects              = local.csi_objects_yaml
          },
          try(each.value.user_assigned_identity_client_id, null) != null ? {
            userAssignedIdentityID = each.value.user_assigned_identity_client_id
          } : {}
        )
      },
      each.value.sync_to_kubernetes_secret ? {
        secretObjects = [
          {
            secretName = each.value.kubernetes_secret_name
            type       = each.value.kubernetes_secret_type
            data = [
              for object in each.value.objects : {
                objectName = object.object_name
                key        = object.secret_key
              }
            ]
          }
        ]
      } : {}
    )
  }
}

# -----------------------------------------------------------------------------
# ESO Strategy (SecretStore + ExternalSecret)
# -----------------------------------------------------------------------------

resource "kubernetes_secret_v1" "eso_service_principal" {
  count = local.is_eso && local.eso_auth_type == "service_principal" ? 1 : 0

  metadata {
    name        = local.eso_service_principal_secret
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }

  type = "Opaque"

  data = {
    (local.eso_service_principal_keys.client_id)     = var.eso.secret_store.auth.service_principal.client_id
    (local.eso_service_principal_keys.client_secret) = var.eso.secret_store.auth.service_principal.client_secret
  }
}

resource "kubernetes_manifest" "secret_store" {
  for_each = local.eso_secret_store_for_each

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = each.value.kind
    metadata = merge(
      {
        name = each.value.name
      },
      each.value.kind == "SecretStore" ? { namespace = var.namespace } : {},
      local.common_metadata
    )
    spec = {
      provider = {
        azurekv = merge(
          {
            tenantId = each.value.tenant_id
            vaultUrl = local.eso_vault_url
            authType = local.eso_auth_type_map[local.eso_auth_type]
          },
          local.eso_auth_type == "workload_identity" ? {
            serviceAccountRef = merge(
              {
                name = each.value.auth.workload_identity.service_account_name
              },
              local.eso_service_account_namespace != null ? { namespace = local.eso_service_account_namespace } : {}
            )
          } : {},
          local.eso_auth_type == "workload_identity" && local.eso_workload_identity_client_id != null ? {
            identityId = local.eso_workload_identity_client_id
          } : {},
          local.eso_auth_type == "managed_identity" && local.eso_managed_identity_id != null ? {
            identityId = local.eso_managed_identity_id
          } : {},
          local.eso_auth_type == "service_principal" ? {
            authSecretRef = {
              clientId = {
                name = local.eso_service_principal_secret
                key  = local.eso_service_principal_keys.client_id
              }
              clientSecret = {
                name = local.eso_service_principal_secret
                key  = local.eso_service_principal_keys.client_secret
              }
            }
          } : {}
        )
      }
    }
  }

  depends_on = [kubernetes_secret_v1.eso_service_principal]
}

resource "kubernetes_manifest" "external_secret" {
  for_each = local.eso_external_secrets

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = merge(
      {
        name      = each.value.name
        namespace = var.namespace
      },
      local.common_metadata
    )
    spec = merge(
      {
        secretStoreRef = {
          name = var.eso.secret_store.name
          kind = var.eso.secret_store.kind
        }
        target = {
          name = each.value.target.secret_name
        }
        data = [
          {
            secretKey = each.value.target.secret_key
            remoteRef = merge(
              {
                key = each.value.remote_ref.name
              },
              try(each.value.remote_ref.version, null) != null ? { version = each.value.remote_ref.version } : {}
            )
          }
        ]
      },
      try(each.value.refresh_interval, null) != null ? { refreshInterval = each.value.refresh_interval } : {}
    )
  }

  depends_on = [kubernetes_manifest.secret_store]
}
