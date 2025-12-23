# azurerm_kubernetes_secrets Module Security

## Overview

This module manages Kubernetes secrets on AKS using three strategies:

- **manual**: Key Vault → Terraform → Kubernetes Secret
- **csi**: Key Vault → CSI SecretProviderClass
- **eso**: Key Vault → External Secrets Operator

Each strategy has different security implications. Choose based on your threat model and operational needs.

## Strategy Security Notes

### Manual (KV → TF → K8s Secret)
- **Secrets in Terraform state**: values are stored in state; use a secure backend and strict RBAC.
- **Plan output**: avoid logging or sharing plan output if it contains sensitive values.
- **Rotation**: manual rotation by updating `key_vault_secret_version` and applying.

### CSI (SecretProviderClass)
- **Runtime access**: secrets are retrieved at runtime; state does **not** contain values.
- **Identity**: ensure the CSI identity has **least-privilege** access to Key Vault.
- **Sync to K8s Secret**: if enabled, secrets become regular Kubernetes Secrets (consider workload access controls).

### ESO (SecretStore + ExternalSecret)
- **Runtime access**: secrets are retrieved at runtime; state does **not** contain values.
- **Auth method**: prefer **Workload Identity** over Service Principal.
- **Refresh interval**: set sensibly to avoid excessive API calls.

## Key Vault Access Patterns

- **manual**: Terraform caller must have `Key Vault Secrets Officer` (or equivalent) to create/read secrets.
- **csi**: CSI identity (from AKS addon) should have `Key Vault Secrets User`.
- **eso**:
  - Workload Identity: UAI gets `Key Vault Secrets User`.
  - Service Principal: SP object_id gets `Key Vault Secrets User`.
  - Managed Identity: MI object_id gets `Key Vault Secrets User`.

## Hardening Checklist

- [ ] Use **Workload Identity** for ESO where possible.
- [ ] Restrict Key Vault access to minimum required roles.
- [ ] Avoid exposing `client_secret` in logs/outputs.
- [ ] Use private networks for Key Vault where feasible.
- [ ] Enable audit logging for Key Vault access.
- [ ] Review Kubernetes RBAC for namespaces using secrets.

## Incident Response

If a secret is suspected to be compromised:

1. Rotate in Key Vault.
2. For manual: update `key_vault_secret_version` and apply.
3. For CSI/ESO: refresh/sync and redeploy workloads.
4. Audit access logs and update RBAC policies.

---

**Module Version**: 1.0.0  
**Last Updated**: 2025-12-23  
**Security Contact**: security@yourorganization.com
