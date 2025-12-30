# Complete AKS Secrets Example (CSI)

This example demonstrates the **CSI** strategy using `SecretProviderClass` with optional sync to a Kubernetes Secret.

## Features

- AKS cluster with Key Vault Secrets Provider enabled
- SecretProviderClass configuration for Azure Key Vault
- Optional sync to Kubernetes Secret

## Prerequisites

- CSI driver is enabled via the AKS addon (`key_vault_secrets_provider`)

## Usage

```bash
terraform init
# Stage 1: create AKS first (kubernetes_manifest requires a live cluster)
terraform apply -target=module.kubernetes_cluster

# Stage 2: apply the SecretProviderClass and remaining resources
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
