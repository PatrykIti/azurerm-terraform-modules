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
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
