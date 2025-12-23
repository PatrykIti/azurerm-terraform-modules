# Secure AKS Secrets Example (ESO + Workload Identity)

This example demonstrates the **ESO** strategy with Workload Identity.

## Features

- AKS with Workload Identity enabled
- User-assigned identity + federated identity credential
- SecretStore + ExternalSecret in the cluster

## Prerequisites

- External Secrets Operator installed in the cluster

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
