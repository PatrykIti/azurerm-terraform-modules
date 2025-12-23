# Basic AKS Secrets Example (manual)

This example demonstrates the **manual** strategy: Key Vault → Terraform → Kubernetes Secret.

## Features

- Creates a minimal AKS cluster
- Reads a secret from Azure Key Vault
- Creates a Kubernetes Secret via Terraform

## Notes

- Secret values are stored in Terraform state.
- Key Vault name must be globally unique (adjust `key_vault_name` if needed).

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
