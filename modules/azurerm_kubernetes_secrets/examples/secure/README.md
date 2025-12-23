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
# Stage 1: create AKS first (kubernetes_manifest requires a live cluster)
terraform apply -target=module.kubernetes_cluster

# Install ESO in the cluster, then apply the SecretStore/ExternalSecret
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
