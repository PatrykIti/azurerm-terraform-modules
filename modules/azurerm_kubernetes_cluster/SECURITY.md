# azurerm_kubernetes_cluster Module Security

## Overview

This document describes the security features exposed by the `azurerm_kubernetes_cluster` module and how to configure a hardened AKS deployment. Use this module's security documentation as the baseline for other modules, and document any deviations required by service-specific constraints.

The `examples/secure` configuration is the reference implementation for hardened deployments. Review and adapt it for your environment.

## Security Controls

### Identity and Access

- **Managed Identity (Preferred)**: Use `identity` (default is SystemAssigned) and avoid `service_principal` unless required for legacy scenarios.
- **Azure AD RBAC**: Configure `azure_active_directory_role_based_access_control` with `azure_rbac_enabled = true`.
- **Disable Local Accounts**: Set `features.local_account_disabled = true`.
- **Workload Identity**: Enable `features.workload_identity_enabled` and `features.oidc_issuer_enabled` for pod identity scenarios.

### Network Security

- **Private Cluster**: Configure `private_cluster_config.private_cluster_enabled = true` and set `private_dns_zone_id` when required.
- **API Server Access**: Restrict `api_server_access_profile.authorized_ip_ranges`.
  - Note: authorized IP ranges are mutually exclusive with private cluster mode.
- **Network Policy**: Use `network_profile.network_policy` (e.g., `azure` or `cilium`) and the appropriate `network_plugin`.

### Encryption and Key Management

- **Disk Encryption Set**: Configure `disk_encryption_set_id` for node disk encryption.
- **KMS for etcd**: Configure `key_management_service` with a Key Vault key (`key_vault_key_id`) and enforce private access when required (`key_vault_network_access = "Private"`).

### Secrets Management

- **Key Vault Secrets Provider (CSI)**: Configure `key_vault_secrets_provider` for secret rotation.
  - If your workload cannot tolerate CSI sync latency, consider alternative secret delivery patterns and document the trade-offs.

### Monitoring and Threat Protection

- **Azure Monitor**: Configure `oms_agent` and `diagnostic_settings` for control plane logs and metrics.
- **Microsoft Defender**: Enable `microsoft_defender` with a Log Analytics workspace.
- **Metrics Labels/Annotations**: Use `monitor_metrics` only with approved label/annotation allowlists.

## Secure Example

Use the hardened example at:

```
modules/azurerm_kubernetes_cluster/examples/secure
```

Key hardening actions in that example include:

- `features.local_account_disabled = true`
- `features.run_command_enabled = false`
- `features.workload_identity_enabled = true` and `features.oidc_issuer_enabled = true`
- `azure_active_directory_role_based_access_control.azure_rbac_enabled = true`
- `microsoft_defender` and `diagnostic_settings` enabled
- Restricted `api_server_access_profile.authorized_ip_ranges` (replace placeholder ranges)
- Optional private cluster configuration (enable when required)

## Defaults vs Hardened Configuration

Some security features require explicit enablement. Review defaults in `variables.tf` and set these for hardened deployments:

- `features.local_account_disabled`
- `features.azure_policy_enabled`
- `features.run_command_enabled` (disable for hardened posture)
- `private_cluster_config.private_cluster_enabled`
- `api_server_access_profile.authorized_ip_ranges`
- `microsoft_defender` and `diagnostic_settings`

## Common Misconfigurations

- **Wide-open API server**: Leaving `authorized_ip_ranges` as `0.0.0.0/0`.
- **Public cluster without restrictions**: Using non-private clusters without a restricted API server profile.
- **Legacy identity**: Using `service_principal` when managed identity is supported.
- **Missing diagnostics**: Skipping `diagnostic_settings` and Defender for Cloud integration.

## Reporting Security Issues

Report security vulnerabilities through your organization's approved private channel. Do NOT create public issues for security reports.

## References

- Azure AKS security baseline documentation
- Azure Policy for Kubernetes
- Microsoft Defender for Cloud (Containers)
