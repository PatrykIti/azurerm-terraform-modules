# Terraform Azure Kubernetes Secrets Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

This module provides a unified, user-friendly API for managing Kubernetes secrets on AKS using three strategies:

- **manual**: Key Vault → Terraform → Kubernetes Secret (manual rotation, secrets in state)
- **csi**: Key Vault → CSI SecretProviderClass (runtime sync, optional K8s Secret sync)
- **eso**: Key Vault → External Secrets Operator (runtime sync with refresh and mapping)

## Decision Tree (Quick Pick)

- **manual**: choose when you need predictable rollouts/`helm upgrade` and accept secrets in state
- **csi**: choose when you want runtime sync via SecretProviderClass
- **eso**: choose when you want runtime sync with ESO features (refresh, mapping)

## Security Notes

- **manual** writes secret values to Terraform state — use a secure backend and strict RBAC.
- **csi/eso** keep secrets out of state, but rely on runtime components in the cluster.

## CSI/ESO Planning Note

`kubernetes_manifest` requires a live cluster (and CRDs) at plan time. For brand-new AKS clusters,
apply in two stages: create the cluster first, then apply this module once CSI/ESO is installed.
If the AKS cluster and this module live in the same Terraform configuration/state, use a two-step
apply (target the cluster first, then install CSI/ESO and run `terraform apply` again). If AKS is
managed elsewhere, make sure kubeconfig and the required CRDs exist before applying this module.

## Usage

### Manual (KV → TF → K8s Secret)
```hcl
module "kubernetes_secrets" {
  source = "path/to/azurerm_kubernetes_secrets"

  strategy  = "manual"
  namespace = "app"
  name      = "app-secrets"

  manual = {
    key_vault_id           = azurerm_key_vault.example.id
    kubernetes_secret_type = "Opaque"
    secrets = [
      {
        name                     = "db-password"
        key_vault_secret_name    = "db-password"
        key_vault_secret_version = null
        kubernetes_secret_key    = "DB_PASSWORD"
      }
    ]
  }
}
```

### CSI (SecretProviderClass)
```hcl
module "kubernetes_secrets" {
  source = "path/to/azurerm_kubernetes_secrets"

  strategy  = "csi"
  namespace = "app"
  name      = "app-spc"

  csi = {
    tenant_id                 = var.tenant_id
    key_vault_name            = azurerm_key_vault.example.name
    sync_to_kubernetes_secret = true
    kubernetes_secret_name    = "app-secrets"
    objects = [
      {
        name        = "db-password"
        object_name = "db-password"
        object_type = "secret"
        secret_key  = "DB_PASSWORD"
      }
    ]
  }
}
```

### ESO (SecretStore + ExternalSecret)
```hcl
module "kubernetes_secrets" {
  source = "path/to/azurerm_kubernetes_secrets"

  strategy  = "eso"
  namespace = "app"
  name      = "app-eso"

  eso = {
    secret_store = {
      kind           = "SecretStore"
      name           = "kv-store"
      tenant_id      = var.tenant_id
      key_vault_name = azurerm_key_vault.example.name
      auth = {
        type = "workload_identity"
        workload_identity = {
          service_account_name = "eso-sa"
        }
      }
    }
    external_secrets = [
      {
        name = "db-secret"
        remote_ref = {
          name = "db-password"
        }
        target = {
          secret_name = "app-secrets"
          secret_key  = "DB_PASSWORD"
        }
      }
    ]
  }
}
```

### ESO service principal secret keys (optional)
By default, the module stores SP credentials under `clientId` and `clientSecret` and references those keys in `authSecretRef`.
If you need different key names (for example `username`/`password`), override them below. This is still **service principal auth** — only the Secret key names change.

```hcl
module "kubernetes_secrets" {
  # ...
  eso = {
    secret_store = {
      # ...
      auth = {
        type = "service_principal"
        service_principal = {
          client_id     = var.eso_sp_client_id
          client_secret = var.eso_sp_client_secret
          tenant_id     = data.azurerm_client_config.current.tenant_id
          secret_keys = {
            client_id     = "username"
            client_secret = "password"
          }
        }
      }
    }
    # ...
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates the **manual** strategy: Key Vault → Terraform → Kubernetes Secret.
- [Complete](examples/complete) - This example demonstrates the **CSI** strategy using `SecretProviderClass` with optional sync to a Kubernetes Secret.
- [Secure](examples/secure) - This example demonstrates the **ESO** strategy with Workload Identity.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.external_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.secret_provider_class](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.secret_store](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_secret_v1.eso_service_principal](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.manual](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [azurerm_key_vault_secret.manual](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/key_vault_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Annotations to apply to all Kubernetes objects created by the module. | `map(string)` | `{}` | no |
| <a name="input_csi"></a> [csi](#input\_csi) | CSI strategy configuration (SecretProviderClass).<br/><br/>tenant\_id: Azure Tenant ID.<br/>key\_vault\_name: Key Vault name.<br/>user\_assigned\_identity\_client\_id: Optional client ID for user-assigned identity (CSI).<br/>sync\_to\_kubernetes\_secret: Whether to sync to a Kubernetes Secret. | <pre>object({<br/>    tenant_id                        = string<br/>    key_vault_name                   = string<br/>    user_assigned_identity_client_id = optional(string)<br/>    sync_to_kubernetes_secret        = optional(bool, false)<br/>    kubernetes_secret_name           = optional(string)<br/>    kubernetes_secret_type           = optional(string, "Opaque")<br/>    objects = list(object({<br/>      name           = string<br/>      object_name    = string<br/>      object_type    = string<br/>      object_version = optional(string)<br/>      secret_key     = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_eso"></a> [eso](#input\_eso) | External Secrets Operator strategy configuration.<br/><br/>secret\_store: SecretStore/ClusterSecretStore configuration.<br/>external\_secrets: List of ExternalSecret definitions. | <pre>object({<br/>    secret_store = object({<br/>      kind           = string<br/>      name           = string<br/>      tenant_id      = string<br/>      key_vault_url  = optional(string)<br/>      key_vault_name = optional(string)<br/>      auth = object({<br/>        type = string<br/>        workload_identity = optional(object({<br/>          service_account_name      = string<br/>          service_account_namespace = optional(string)<br/>          client_id                 = optional(string)<br/>        }))<br/>        service_principal = optional(object({<br/>          client_id     = string<br/>          client_secret = string<br/>          tenant_id     = string<br/>          secret_keys = optional(object({<br/>            client_id     = optional(string, "clientId")<br/>            client_secret = optional(string, "clientSecret")<br/>          }))<br/>        }))<br/>        managed_identity = optional(object({<br/>          client_id   = optional(string)<br/>          resource_id = optional(string)<br/>        }))<br/>      })<br/>    })<br/>    external_secrets = list(object({<br/>      name             = string<br/>      refresh_interval = optional(string)<br/>      remote_ref = object({<br/>        name    = string<br/>        version = optional(string)<br/>      })<br/>      target = object({<br/>        secret_name = string<br/>        secret_key  = string<br/>      })<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to all Kubernetes objects created by the module. | `map(string)` | `{}` | no |
| <a name="input_manual"></a> [manual](#input\_manual) | Manual strategy configuration (KV -> Terraform -> Kubernetes Secret).<br/><br/>key\_vault\_id: Key Vault ID to read secrets from.<br/>kubernetes\_secret\_type: Kubernetes Secret type (default: Opaque).<br/>secrets: List of mappings from Key Vault secrets to Kubernetes Secret keys. | <pre>object({<br/>    key_vault_id           = string<br/>    kubernetes_secret_type = optional(string, "Opaque")<br/>    secrets = list(object({<br/>      name                     = string<br/>      key_vault_secret_name    = string<br/>      key_vault_secret_version = optional(string)<br/>      kubernetes_secret_key    = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the created Kubernetes objects (Secret / SecretProviderClass / ExternalSecret). | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for created objects. | `string` | n/a | yes |
| <a name="input_strategy"></a> [strategy](#input\_strategy) | Secret management strategy to use. Valid values: manual, csi, eso. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_secret_names"></a> [external\_secret\_names](#output\_external\_secret\_names) | Names of ExternalSecret resources (ESO strategy). |
| <a name="output_kubernetes_secret_name"></a> [kubernetes\_secret\_name](#output\_kubernetes\_secret\_name) | Name of the Kubernetes Secret created by manual strategy or CSI sync. |
| <a name="output_name"></a> [name](#output\_name) | Base name for created Kubernetes objects. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace for created Kubernetes objects. |
| <a name="output_secret_provider_class_name"></a> [secret\_provider\_class\_name](#output\_secret\_provider\_class\_name) | Name of the SecretProviderClass (CSI strategy). |
| <a name="output_secret_store_name"></a> [secret\_store\_name](#output\_secret\_store\_name) | Name of the SecretStore/ClusterSecretStore (ESO strategy). |
| <a name="output_strategy"></a> [strategy](#output\_strategy) | Selected secret management strategy. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
