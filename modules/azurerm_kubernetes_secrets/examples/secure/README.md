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

# Fetch kubeconfig for Helm/kubectl, install ESO, then wait for CRDs
az aks get-credentials -g <resource_group_name> -n <cluster_name> --overwrite-existing
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm upgrade --install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace --set installCRDs=true
kubectl wait --for=condition=Established --timeout=120s crd/secretstores.external-secrets.io
kubectl wait --for=condition=Established --timeout=120s crd/externalsecrets.external-secrets.io

# Apply the SecretStore/ExternalSecret
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
