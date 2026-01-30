# User Assigned Identity Module Documentation

## Overview

This module manages a single Azure User Assigned Identity (UAI) and, optionally, one or more
federated identity credentials (FICs) tied directly to that identity.

## Managed Resources

- `azurerm_user_assigned_identity`
- `azurerm_federated_identity_credential`

## Usage Notes

- The module is **atomic**: it creates exactly one UAI. Additional identity-related resources must live
  in separate modules or higher-level stacks.
- Federated identity credentials are created only when explicitly provided via
  `federated_identity_credentials`.
- Name constraints follow Azure naming rules for `userAssignedIdentities` and `federatedIdentityCredentials`.
- `issuer` must be an HTTPS URL, `subject` must be non-empty, and `audience` must be a non-empty list.
- The provider schema uses `audience` (list) and does not expose a `description` field for federated identity credentials in azurerm 4.57.0.

## Out of Scope

The following are intentionally **not** managed in this module:

- Role assignments / RBAC bindings
- Private endpoints, networking glue, or diagnostics
- Key Vault, Storage, AKS, and other workload-specific integrations
- Service principals or external identity providers

## Additional References

- [SECURITY.md](../SECURITY.md) - Security posture and hardening guidance
- [IMPORT.md](IMPORT.md) - Importing existing identities and credentials
