# Secure AKS Secrets Example (ESO + Workload Identity + Helm)

This example demonstrates the **ESO** strategy with Workload Identity.

## Features

- AKS with Workload Identity enabled
- ESO installed via Helm (CRDs included)
- User-assigned identity + federated identity credential
- SecretStore + ExternalSecret in the cluster

## Prerequisites

- Azure access with permissions to create AKS and Key Vault resources
- Terraform 1.12.2+

## Usage

This example installs ESO via the Helm provider. When the AKS cluster is created in the same
Terraform configuration/state, apply in stages so the CRDs exist before the ESO resources are planned.
If you reuse an existing AKS cluster, skip stage 1.

```bash
terraform init
# Stage 1: create AKS first (providers need a live cluster)
terraform apply -target=module.kubernetes_cluster

# Stage 2: install ESO + CRDs via Helm
terraform apply -target=helm_release.external_secrets

# Stage 3: apply the SecretStore/ExternalSecret
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
