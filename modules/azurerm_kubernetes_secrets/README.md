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

## Usage

### Manual (KV → TF → K8s Secret)
```hcl
module "kubernetes_secrets" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_secrets?ref=AKSSv1.0.0"

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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_secrets?ref=AKSSv1.0.0"

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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_secrets?ref=AKSSv1.0.0"

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

## Examples

<!-- BEGIN_EXAMPLES -->
<!-- Examples list will be auto-generated here -->
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
